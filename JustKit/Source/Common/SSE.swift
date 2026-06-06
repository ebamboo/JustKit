//
//  Created by 姚旭 on 2025/1/12.
//

import Foundation

public enum SSE {
    
    /// 发起一个 SSE（Server-Sent Events）连接
    ///
    /// 默认以 GET 方式请求，并设置 `Accept: text/event-stream` 请求头。
    /// 如需使用 POST 或自定义请求体，可通过 `requestModifier` 修改。
    ///
    /// - Note:
    ///   - 手动取消时不会触发 `completionHandler`。
    ///   - 缓冲区溢出时，连接会被自动终止，并返回错误 `NSError`（domain: `"SSE"`, code: `-1`）。
    ///
    /// - Parameters:
    ///   - url: SSE 服务端地址
    ///   - headers: 附加的自定义请求头，会与默认请求头合并（相同 key 时覆盖默认值）
    ///   - requestModifier: 请求发送前的最终修改机会，可用于设置 httpMethod、httpBody 等
    ///   - eventHandler: 每收到一个完整的 SSE 事件时调用，回调在主线程执行
    ///   - completionHandler: 连接结束时调用（正常完成或发生错误），回调在主线程执行
    /// - Returns: 已启动的 `URLSessionDataTask`，可用于取消请求
    @discardableResult
    public static func dataTask(
        with url: URL,
        headers: [String: String] = [:],
        requestModifier: ((inout URLRequest) -> Void)? = nil,
        eventHandler: @escaping (URLSessionDataTask, SSEEvent) -> Void,
        completionHandler: @escaping (URLSessionDataTask, Error?) -> Void
    ) -> URLSessionDataTask {
        session.dataTask(
            with: url,
            headers: headers,
            requestModifier: requestModifier,
            eventHandler: eventHandler,
            completionHandler: completionHandler
        )
    }
    
    private static let session = SSESession()
    
}

private class SSESession: NSObject, URLSessionDataDelegate {
    
    lazy var urlSession: URLSession = {
        // Note: 根据实际业务场景调整以下参数
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120 // 两次数据传输之间允许的最大间隔，收到数据后重新计时
        configuration.timeoutIntervalForResource = 7 * 24 * 60 * 60 // 请求允许持续的最长时间，到期后系统自动终止
        configuration.httpMaximumConnectionsPerHost = 6 // 同一 Host 允许建立的最大并发网络连接数（HTTP/2 下通常无需调整）
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData  // 忽略本地缓存，每次从服务端获取最新数据
        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil // 使用系统串行 Delegate Queue，保证流式数据按接收顺序处理
        )
    }()
    
    var workList: [Int: SSEWork] = [:]
    let workListQueue = DispatchQueue(label: "sse.session.work")
    
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

private class SSEWork {
    
    let onEvent: (URLSessionDataTask, SSEEvent) -> Void
    let onCompletion: (URLSessionDataTask, Error?) -> Void
    
    var buffer = Data()
    let maxBufferSize: Int = 2 * 1024 * 1024
    
    init(
        onEvent: @escaping (URLSessionDataTask, SSEEvent) -> Void,
        onCompletion: @escaping (URLSessionDataTask, Error?) -> Void
    ) {
        self.onEvent = onEvent
        self.onCompletion = onCompletion
    }
    
    func didReceive(data: Data, dataTask: URLSessionDataTask) {
        if buffer.count + data.count > maxBufferSize {
            let error = NSError(domain: "SSE", code: -1)
            DispatchQueue.main.async { self.onCompletion(dataTask, error) }
            dataTask.cancel()
            return
        }
        buffer.append(data)
        // Note: 根据服务端实际使用的行结束符调整
        // WHATWG SSE 规范支持三种行结束符：LF（\n）、CR（\r）、CRLF（\r\n）
        let delimiterData = "\n\n".data(using: .utf8)!
        while let delimiterRange = buffer.range(of: delimiterData) {
            let eventData = buffer[..<delimiterRange.lowerBound]
            if let eventString = String(data: eventData, encoding: .utf8) {
                // 解析在后台线程完成，仅将结果回调派发到主线程
                let event = SSEEvent(from: eventString)
                DispatchQueue.main.async { self.onEvent(dataTask, event) }
            }
            buffer.removeSubrange(..<delimiterRange.upperBound)
        }
    }
    
    func didComplete(with error: Error?, dataTask: URLSessionDataTask) {
        // 忽略取消类型错误（包括手动取消和缓冲区超限后的 cancel）
        if (error as? URLError)?.code == .cancelled { return }
        DispatchQueue.main.async { self.onCompletion(dataTask, error) }
    }
    
}
