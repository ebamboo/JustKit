//
//  Created by 姚旭 on 2025/1/12.
//

import Foundation

public enum SSE {
    
    private static let session = SSESession()
    
    /// 发起 SSE 连接的静态方法
    /// - Parameters:
    ///   - url: The endpoint for SSE.
    ///   - headers: Custom headers for the request.
    ///   - requestModifier: Allows modification of the URLRequest before sending.
    ///   - eventHandler: Called for every received event.
    ///   - completionHandler: Called when the task completes, with or without error.
    /// - Returns: A URLSessionDataTask that represents the ongoing request.
    @discardableResult
    public static func dataTask(
        with url: URL,
        headers: [String: String] = [:],
        requestModifier: ((inout URLRequest) -> Void)? = nil,
        eventHandler: @escaping (URLSessionDataTask, SSEEvent) -> Void,
        completionHandler: @escaping (URLSessionDataTask, Error?) -> Void
    ) -> URLSessionDataTask {
        session.dataTask(with: url, headers: headers, requestModifier: requestModifier,
                         eventHandler: eventHandler, completionHandler: completionHandler)
    }
    
}

/// SSE 会话管理器
/// 负责 URLSession 生命周期管理、任务映射维护和 delegate 回调分发。
/// 内部通过串行队列保证 workList 的线程安全访问。
private class SSESession: NSObject, URLSessionDataDelegate {
    
    /// SSE 专用 URLSession
    /// - timeoutIntervalForRequest: 单次数据接收的最大等待时间，SSE 长连接场景下需要设置较大值
    /// - timeoutIntervalForResource: 整个请求（从发起到结束）的最大存活时间
    /// - httpMaximumConnectionsPerHost: 限制对同一 host 只维持一个连接，避免 SSE 连接堆积
    /// - requestCachePolicy: SSE 是实时事件流，必须忽略缓存
    /// - delegateQueue: nil 表示由系统创建并发队列执行回调，workList 的线程安全由 workListQueue 保证
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1200
        configuration.timeoutIntervalForResource = 3600
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /// 任务映射表：以 URLSessionDataTask.taskIdentifier 为 key，关联对应的事件处理器
    private var workList: [Int: SSEWork] = [:]
    /// 串行队列，保护 workList 的并发读写安全
    private let workListQueue = DispatchQueue(label: "sse.session.work")
    
    @discardableResult
    func dataTask(
        with url: URL,
        headers: [String: String] = [:],
        requestModifier: ((inout URLRequest) -> Void)? = nil,
        eventHandler: @escaping (URLSessionDataTask, SSEEvent) -> Void,
        completionHandler: @escaping (URLSessionDataTask, Error?) -> Void
    ) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        // 默认 GET 请求，Accept 标记为 SSE 事件流类型
        // 如需 POST 等其他方式，可通过 requestModifier 覆盖
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        requestModifier?(&request)
        let task = urlSession.dataTask(with: request)
        let work = SSEWork(onEvent: eventHandler, onCompletion: completionHandler)
        workListQueue.sync { workList[task.taskIdentifier] = work }
        task.resume()
        return task
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let work = workListQueue.sync { workList[dataTask.taskIdentifier] }
        guard let work else { return }
        work.didReceive(data: data, dataTask: dataTask)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let work = workListQueue.sync { workList.removeValue(forKey: task.taskIdentifier) }
        guard let work, let dataTask = task as? URLSessionDataTask else { return }
        work.didComplete(with: error, dataTask: dataTask)
    }
    
}

/// 单个 SSE 任务的事件处理单元
/// 负责接收原始字节流，按 SSE 规范的事件分隔符拆分，解析后回调给调用方。
/// 每个 URLSessionDataTask 对应一个 SSEWork 实例。
private class SSEWork {
    
    private let onEvent: (URLSessionDataTask, SSEEvent) -> Void
    private let onCompletion: (URLSessionDataTask, Error?) -> Void
    
    /// NSLock 保护 buffer 的并发访问（URLSession 回调可能在并发队列上触发）
    private let lock = NSLock()
    /// 增量接收缓冲区：URLSession 按 TCP 分包回调数据，一个完整的 SSE 事件可能跨多次回调，
    /// 因此需要缓冲区拼接，直到检测到完整的事件分隔符后再解析。
    private var buffer = Data()
    /// 缓冲区上限（200MB），防止异常数据流导致内存无限增长。超限时直接取消任务。
    private let maxBufferSize: Int = 200 * 1024 * 1024
    
    init(
        onEvent: @escaping (URLSessionDataTask, SSEEvent) -> Void,
        onCompletion: @escaping (URLSessionDataTask, Error?) -> Void
    ) {
        self.onEvent = onEvent
        self.onCompletion = onCompletion
    }
    
    func didReceive(data: Data, dataTask: URLSessionDataTask) {
        lock.lock()
        defer { lock.unlock() }
        if buffer.count + data.count > maxBufferSize {
            dataTask.cancel()
            return
        }
        buffer.append(data)
        // SSE 规范：事件之间以空行（"\n\n"）分隔
        // 参考 https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
        let delimiterData = "\n\n".data(using: .utf8)!
        while let delimiterRange = buffer.range(of: delimiterData) {
            let eventData = buffer[..<delimiterRange.lowerBound]
            if let eventString = String(data: eventData, encoding: .utf8) {
                onEvent(dataTask, SSEEvent(from: eventString))
            }
            buffer.removeSubrange(..<delimiterRange.upperBound)
        }
    }
    
    func didComplete(with error: Error?, dataTask: URLSessionDataTask) {
        onCompletion(dataTask, error)
    }
    
}
