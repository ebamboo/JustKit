//
//  Created by 姚旭 on 2025/12/5.
//

import HandyJSON
import Alamofire


//-------------------- 自定义 HTTP 调试工具


//private extension HTTP {
//    
//    static func logRequest(_ request: HTTPRequest, taskID: UUID) {
//        #if DEBUG
//        Debugger.printTaskRequest(request, taskID: taskID)
//        Debugger.addTask(with: request, taskID: taskID)
//        #endif
//    }
//    
//    static func logResult(_ result: Result<HTTPResponse, HTTPError>, taskID: UUID) {
//        #if DEBUG
//        Debugger.printTaskResult(result, taskID: taskID)
//        Debugger.updateTask(with: result, taskID: taskID)
//        #endif
//    }
//    
//}
//
//// MARK: - debug
//
//class Debugger {
//    
//    class Task {
//        let id: UUID
//        let date: Date
//        let request: HTTPRequest
//        init(id: UUID, date: Date, request: HTTPRequest) {
//            self.id = id
//            self.date = date
//            self.request = request
//        }
//        var result: Result<HTTPResponse, HTTPError>?
//    }
//    
//    private(set) static var tasks: [Task] = []
//    
//    static func addTask(with request: HTTPRequest, taskID: UUID) {
//        let task = Task(id: taskID, date: Date(), request: request)
//        tasks.append(task)
//        if tasks.count > 100 { tasks.removeFirst(tasks.count-100)}
//    }
//    
//    static func updateTask(with result: Result<HTTPResponse, HTTPError>, taskID: UUID) {
//        let task = tasks.first { $0.id == taskID }
//        task?.result = result
//    }
//    
//    static func clearTasks() {
//        tasks = []
//    }
//    
//}
//
//extension Debugger {
//    
//    static func printTaskRequest(_ request: HTTPRequest, taskID: UUID) {
//        let id = {
//            taskID.uuidString
//        }()
//        print("request id = \(id)")
//        let line = {
//            "\(request.method.rawValue) \(request.url)"
//        }()
//        print("request line = \(line)")
//        let headers = {
//            let headersData = try! JSONSerialization.data(withJSONObject: request.headers, options: .prettyPrinted)
//            let headersString = String(data: headersData, encoding: .utf8)!
//            return headersString
//        }()
//        print("request headers = \(headers)")
//        let body = {
//            switch request.body {
//            case .none:
//                return "null"
//            case .binary:
//                return "binary 数据"
//            case .plain(let text, _):
//                return text
//            case .json(let params):
//                let paramsData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
//                let paramsString = String(data: paramsData, encoding: .utf8)!
//                return paramsString
//            case .form(let params):
//                let paramsList = params.keys.map { "\($0)=\(params[$0]!)" }
//                let paramsString = paramsList.joined(separator: "&")
//                return paramsString
//            case .multipart(let normals, let files):
//                var formDataList = normals
//                files.forEach { file in
//                    switch file {
//                    case .fileData(_, let name, _, _):
//                        formDataList[name] = "Data 方式上传的二进制数据"
//                    case .fileURL(_, let name, _, _):
//                        formDataList[name] = "URL 方式上传的二进制数据"
//                    }
//                }
//                let paramsData = try! JSONSerialization.data(withJSONObject: formDataList, options: .prettyPrinted)
//                let paramsString = String(data: paramsData, encoding: .utf8)!
//                return paramsString
//            case .fileData:
//                return "Data 方式上传的二进制数据"
//            case .fileURL(let fileURL):
//                return "URL 方式上传的二进制数据：\(fileURL.absoluteString)"
//            }
//        }()
//        print("request body = \(body)")
//    }
//    
//    static func printTaskResult(_ result: Result<HTTPResponse, HTTPError>, taskID: UUID) {
//        switch result {
//        case .success(let response):
//            let id = {
//                taskID.uuidString
//            }()
//            print("response id = \(id)")
//            let headers = {
//                let headersData = try! JSONSerialization.data(withJSONObject: response.headers, options: .prettyPrinted)
//                let headersString = String(data: headersData, encoding: .utf8)!
//                return headersString
//            }()
//            print("response headers = \(headers)")
//            let body = {
//                guard let bodyData = response.body, !bodyData.isEmpty else { return "null" }
//                if let jsonObject = try? JSONSerialization.jsonObject(with: bodyData, options: []) {
//                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//                    let jsonString = String(data: jsonData, encoding: .utf8)!
//                    return jsonString
//                }
//                if let text = String(data: bodyData, encoding: .utf8) {
//                    return text
//                }
//                return "body 数据存在但无法转为 JSON 或者字符串"
//            }()
//            print("response body = \(body)")
//        case .failure(let error):
//            let id = {
//                taskID.uuidString
//            }()
//            print("response id = \(id)")
//            let error = {
//                error.errorDescription ?? "alamofire 未返回错误描述"
//            }()
//            print("response error = \(error)")
//        }
//    }
//    
//}


//-------------------- 使用 HandyJson 解析业务数据


//// MARK: - core
//
//struct BusinessBody {
//    let code: Int
//    let message: String?
//    let data: Any?
//}
//
//enum BusinessError: Error {
//    case decodingError(message: String)
//    case alamofire(error: HTTPError)
//    var message: String {
//        switch self {
//        case .decodingError(let message):
//            return message
//        case .alamofire(let error):
//            return error.errorDescription ?? "alamofire未返回错误描述"
//        }
//    }
//}
//
//extension HTTP {
//
//    /// 解析响应体，返回 BusinessBody 类型数据。
//    /// 不解析实际的业务数据
//    @discardableResult
//    static func dataRequestForBody(
//        _ request: HTTPRequest,
//        requestModifier: RequestModifier? = nil,
//        completion: @escaping (_ result: Result<BusinessBody, BusinessError>) -> Void
//    ) -> DataTask {
//        let task = dataRequest(request, requestModifier: requestModifier) { result in
//            switch result {
//            case .success(let response):
//                guard let jsonData = response.body, !jsonData.isEmpty,
//                      let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//                      let code = jsonObject["code"] as? Int else {
//                    completion(.failure(.decodingError(message: "服务器返回数据格式错误")))
//                    return
//                }
//                let body = BusinessBody(
//                    code: code,
//                    message: jsonObject["message"] as? String,
//                    data: jsonObject["data"]
//                )
//                completion(.success(body))
//            case .failure(let error):
//                completion(.failure(.alamofire(error: error)))
//            }
//        }
//        return task
//    }
//
//    /// 直接解析业务数据，返回指定类型的数据。
//    ///
//    /// Payload 只接受以下类型：
//    /// [M]、M、布尔、整形、浮点型、字符串、数组、字典。
//    /// 其中 M 遵循 HandyJSON 协议
//    /// 数组和字典的元素只接受以下类型：布尔、整形、浮点型、字符串、数组、字典
//    ///
//    /// 注意：传入其他类型则结果未定义。
//    @discardableResult
//    static func dataRequestForPayload<Payload>(
//        _ request: HTTPRequest,
//        requestModifier: RequestModifier? = nil,
//        payloadType: Payload.Type,
//        completion: @escaping (_ result: Result<Payload, BusinessError>) -> Void
//    ) -> DataTask {
//        let task = dataRequest(request, requestModifier: requestModifier) { result in
//            switch result {
//            case .success(let response):
//                guard let jsonData = response.body, !jsonData.isEmpty,
//                      let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//                      let _ = jsonObject["code"] as? Int else {
//                    completion(.failure(.decodingError(message: "服务器返回数据格式错误")))
//                    return
//                }
//                let result: Result<Payload, BusinessError> = {
//                    guard let data = jsonObject["data"] else {
//                        return .failure(.decodingError(message: "data数据为空"))
//                    }
//                    if let ListType = Payload.self as? any DecodableArray.Type {
//                        guard let list = ListType.deserialize(from: data as? [Any]) else {
//                            return .failure(.decodingError(message: "data数据无法解析为模型数组"))
//                        }
//                        return .success(list.compactMap({ $0 }) as! Payload)
//                    }
//                    if let ModelType = Payload.self as? any HandyJSON.Type {
//                        guard let model = ModelType.deserialize(from: data as? [String: Any]) else {
//                            return .failure(.decodingError(message: "data数据无法解析为模型"))
//                        }
//                        return .success(model as! Payload)
//                    }
//                    if let data = data as? Payload {
//                        return .success(data)
//                    }
//                    return .failure(.decodingError(message: "data数据无法解析为\(Payload.self)"))
//                }()
//                completion(result)
//            case .failure(let error):
//                completion(.failure(.alamofire(error: error)))
//            }
//        }
//        return task
//    }
//
//}
//
//// MARK: - support
//
//protocol DecodableArray {
//    associatedtype DecodableElement
//    static func deserialize(from array: [Any]?) -> [DecodableElement?]?
//}
//
//extension Array: DecodableArray where Element: HandyJSON {
//    typealias DecodableElement = Element
//}
