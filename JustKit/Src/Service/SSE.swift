//
//  Created by 姚旭 on 2025/1/12.
//

import Foundation

struct SSE {
    
    /// a static method request for initiating SSE connections:
    /// - Parameters:
    ///   - url: The endpoint for SSE.
    ///   - headers: Custom headers for the request.
    ///   - requestModifier: Allows modification of the URLRequest before sending.
    ///   - eventHandler: Called for every received event.
    ///   - completionHandler: Called when the task completes, with or without error.
    /// - Returns: A URLSessionDataTask that represents the ongoing request.
    @discardableResult
    static func request(with url: URL,
                        headers: [String: String] = [:],
                        requestModifier: ((inout URLRequest) -> Void)? = nil,
                        eventHandler: @escaping (URLSessionDataTask, SSEEvent) -> Void,
                        completionHandler: @escaping (URLSessionDataTask, Error?) -> Void)
    -> URLSessionDataTask {
        let task = SSESession.shared.request(with: url,
                                             headers: headers,
                                             requestModifier: requestModifier,
                                             eventHandler: eventHandler,
                                             completionHandler: completionHandler)
        return task
    }
    
}

fileprivate class SSESession: NSObject, URLSessionDataDelegate {
    
    static let shared = SSESession()
    
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private var workList: [Int: SSESessionWork] = [:]
    
    @discardableResult
    func request(with url: URL,
                 headers: [String: String] = [:],
                 requestModifier: ((inout URLRequest) -> Void)? = nil,
                 eventHandler: @escaping (URLSessionDataTask, SSEEvent) -> Void,
                 completionHandler: @escaping (URLSessionDataTask, Error?) -> Void)
    -> URLSessionDataTask {
        var request = URLRequest(url: url)
        requestModifier?(&request)
        request.httpMethod = "GET"
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        let task = session.dataTask(with: request)
        let work = SSESessionWork(onEvent: eventHandler, onCompletion: completionHandler)
        workList[task.taskIdentifier] = work
        task.resume()
        return task
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let work = workList[dataTask.taskIdentifier] else { return }
        work.didReceive(data: data, dataTask: dataTask)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard let work = workList[task.taskIdentifier] else { return }
        work.didComplete(with: error, dataTask: task)
        workList.removeValue(forKey: task.taskIdentifier)
        
        
        /*if let response = task.response as? HTTPURLResponse, response.statusCode == 401 {
            // 统一处理未登录情况
        }*/
    }
    
}

fileprivate class SSESessionWork {
    
    private let onEvent: (URLSessionDataTask, SSEEvent) -> Void
    private let onCompletion: (URLSessionDataTask, Error?) -> Void
    
    private let lock = NSLock()
    private var buffer = Data()
    
    init(onEvent: @escaping (URLSessionDataTask, SSEEvent) -> Void,
         onCompletion: @escaping (URLSessionDataTask, Error?) -> Void) {
        self.onEvent = onEvent
        self.onCompletion = onCompletion
    }
    
    func didReceive(data: Data, dataTask: URLSessionDataTask) {
        lock.lock()
        defer { lock.unlock() }
        buffer.append(data)
        let delimiterData = "\n\n".data(using: .utf8)!
        while let delimiterRange = buffer.range(of: delimiterData) {
            let eventData = buffer[..<delimiterRange.lowerBound]
            if let eventString = String(data: eventData, encoding: .utf8) {
                onEvent(dataTask, SSEEvent(from: eventString))
            }
            buffer.removeSubrange(..<delimiterRange.upperBound)
        }
    }
    
    func didComplete(with error: Error?, dataTask: URLSessionTask) {
        onCompletion(dataTask as! URLSessionDataTask, error)
    }
    
}
