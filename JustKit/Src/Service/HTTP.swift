//
//  Created by 姚旭 on 2021/11/19.
//

import Alamofire
import Combine

// MARK: - core

/// HTTP 请求协议，定义请求的基本要素
/// 遵循此协议的类型可以表示一个完整的 HTTP 请求
protocol HTTPRequest {
    
    /// HTTP 请求方法（GET、POST、PUT、DELETE 等）
    var method: HTTP.Method { get }
    
    /// HTTP 请求的完整 URL 地址
    /// - NOTE:
    ///   1. 若请求需要 query 参数或者 fragment 参数，请在此处拼接
    ///   2. 请注意 url 中是否包含非法字符或者其他可能引起歧义的字符
    ///   请根据实际业务需求进行百分号编码
    var url: String { get }
    
    /// HTTP 请求头部字段字典
    var headers: [String: String] { get }
    
    /// HTTP 请求体内容，支持多种数据格式
    var body: HTTP.Body { get }
    
}

/// HTTP 响应结构体，封装了 HTTP 请求的响应信息
struct HTTPResponse {
    
    /// HTTP 响应头部字段字典
    /// - NOTE: HTTP 头部字段的名称是不区分大小写的
    ///   例如 content-type， Content-Type, CONTENT-TYPE 是等价的
    ///   因此，在查询时统一转换为小写或大写
    let headers: [String: Any]
    
    /// HTTP 响应体数据，原始二进制格式
    /// - NOTE: 此字段为可选类型，因为某些响应可能没有主体（如 HEAD 请求或 204 No Content 响应）
    let body: Data?
    
}

/// HTTP 请求失败返回的错误信息
typealias HTTPError = AFError

/// HTTP 请求失败全局发布者
/// 订阅此消息，可选择性地统一处理某些失败情况
/// 例如：response?.statusCode == 401 表示未登录或登录失效可以提示用户登录
let httpRequestDidFail = PassthroughSubject<HTTPRequestFailureContext, Never>()
struct HTTPRequestFailureContext {
    /// Alamofire error
    let error: HTTPError
    /// The URL request sent to the server.
    let request: URLRequest?
    /// The server's response to the URL request.
    let response: HTTPURLResponse?
}

extension HTTP {
    
    /// 普通数据请求
    /// - Parameters:
    ///   - request: 遵循 HTTPRequest 协议的请求对象
    ///   - requestModifier: 请求修改器，可用于自定义请求
    ///   - completion: 完成回调，返回结果或错误
    /// - Returns: 返回可管理的数据任务对象
    /// - NOTE: `request.body` 不能是   `.multipart`、`.fileData` 、 `.fileURL` 任一类型，否则本次请求体为空
    @discardableResult
    static func dataRequest(
        _ request: HTTPRequest,
        requestModifier: RequestModifier? = nil,
        completion: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> DataTask {
        let task = AF.request(
            request.url,
            method: request.method,
            parameters: request.body.params,
            encoding: request.body.encoding,
            headers: HTTPHeaders(request.headers),
            requestModifier: requestModifier
        )
        task.validate()
        logRequest(request, taskID: task.id)
        task.response { [taskID = task.id] dataResponse in
            let result: Result<HTTPResponse, HTTPError>
            if let error = dataResponse.error {
                httpRequestDidFail.send(
                    .init(
                        error: error,
                        request: dataResponse.request,
                        response: dataResponse.response
                    )
                )
                result = .failure(error)
            } else {
                let headers = dataResponse.response?.allHeaderFields as? [String: Any] ?? [:]
                let body = dataResponse.data
                result = .success(.init(headers: headers, body: body))
            }
            completion(result)
            logResult(result, taskID: taskID)
        }
        return task
    }
    
    /// 文件上传请求
    /// - Parameters:
    ///   - request: 遵循 HTTPRequest 协议的请求对象
    ///   - requestModifier: 请求修改器，可用于自定义请求
    ///   - progress: 上传进度回调
    ///   - completion: 完成回调，返回结果或错误
    /// - Returns: 返回可管理的上传任务对象
    /// - NOTE: `request.body` 必须是  `.multipart`、`.fileData` 、 `.fileURL` 任一类型，否则本次请求体为空
    @discardableResult
    static func uploadRequest(
        _ request: HTTPRequest,
        requestModifier: RequestModifier? = nil,
        progress: @escaping (_ progress: Progress) -> Void = { _ in },
        completion: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> UploadTask {
        let task: UploadRequest
        switch request.body {
        case .fileData(let fileData):
            task = AF.upload(
                fileData,
                to: request.url,
                method: request.method,
                headers: HTTPHeaders(request.headers),
                requestModifier: requestModifier
            )
        case .fileURL(let fileURL):
            task = AF.upload(
                fileURL,
                to: request.url,
                method: request.method,
                headers: HTTPHeaders(request.headers),
                requestModifier: requestModifier
            )
        default:
            task = AF.upload(
                multipartFormData: { request.body.append(to: $0) },
                to: request.url,
                method: request.method,
                headers: HTTPHeaders(request.headers),
                requestModifier: requestModifier
            )
        }
        task.validate()
        task.uploadProgress(closure: progress)
        logRequest(request, taskID: task.id)
        task.response { [taskID = task.id] uploadResponse in
            let result: Result<HTTPResponse, HTTPError>
            if let error = uploadResponse.error {
                httpRequestDidFail.send(
                    .init(
                        error: error,
                        request: uploadResponse.request,
                        response: uploadResponse.response
                    )
                )
                result = .failure(error)
            } else {
                let headers = uploadResponse.response?.allHeaderFields as? [String: Any] ?? [:]
                let body = uploadResponse.data
                result = .success(.init(headers: headers, body: body))
            }
            completion(result)
            logResult(result, taskID: taskID)
        }
        return task
    }
    
    /// 文件下载请求
    /// - Parameters:
    ///   - request: 遵循 HTTPRequest 协议的请求对象
    ///   - destination: 文件下载目标位置
    ///   - requestModifier: 请求修改器，可用于自定义请求
    ///   - progress: 下载进度回调
    ///   - completion: 完成回调，返回结果或错误
    /// - Returns: 返回可管理的下载任务对象
    /// - NOTE:
    ///   1. 若成功则响应 body 为本地储存路径
    ///   2. `request.body` 不能是  `.multipart`、`.fileData` 、 `.fileURL` 任一类型，否则本次请求体为空
    @discardableResult
    static func downloadRequest(
        _ request: HTTPRequest,
        to destination: DownloadFileDestination? = nil,
        requestModifier: RequestModifier? = nil,
        progress: @escaping (_ progress: Progress) -> Void = { _ in },
        completion: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> DownloadTask {
        let task = AF.download(
            request.url,
            method: request.method,
            parameters: request.body.params,
            encoding: request.body.encoding,
            headers: HTTPHeaders(request.headers),
            requestModifier: requestModifier,
            to: destination
        )
        task.validate()
        task.downloadProgress(closure: progress)
        logRequest(request, taskID: task.id)
        task.response { [taskID = task.id] downloadResponse in
            let result: Result<HTTPResponse, HTTPError>
            if let error = downloadResponse.error {
                httpRequestDidFail.send(
                    .init(
                        error: error,
                        request: downloadResponse.request,
                        response: downloadResponse.response
                    )
                )
                result = .failure(error)
            } else {
                let headers = downloadResponse.response?.allHeaderFields as? [String: Any] ?? [:]
                let body = "最终文件路径为 destination 所定义".data(using: .utf8)
                result = .success(.init(headers: headers, body: body))
            }
            completion(result)
            logResult(result, taskID: taskID)
        }
        return task
    }
    
}

// MARK: - support

struct HTTP {
    
    /// HTTP 请求方法类型
    typealias Method = Alamofire.HTTPMethod
    
    /// HTTP 请求体类型枚举，支持多种数据格式
    enum Body {
        
        /// 空请求体，不包含任何数据
        case none
        
        /// 二进制数据请求体
        /// - Parameters:
        ///   - data: 二进制数据内容
        ///   - mimeType: 可选的 MIME 类型，用于内部自动设置 Content-Type 头部
        case binary(_ data: Data, mimeType: String?)
        
        /// 纯文本请求体
        /// - Parameters:
        ///   - text: 文本内容
        ///   - mimeType: 可选的 MIME 类型，用于内部自动设置 Content-Type 头部
        case plain(_ text: String, mimeType: String?)
        
        /// JSON 格式请求体
        /// - Parameter params: JSON 参数字典，将自动转换为 JSON 格式
        ///   会自动设置 Content-Type 为 "application/json"
        case json(_ params: [String: Any])
        
        /// 表单格式请求体
        /// - Parameter params: 表单参数字典，将编码为 x-www-form-urlencoded 格式
        ///   会自动设置 Content-Type 为 "application/x-www-form-urlencoded"
        case form(_ params: [String: String])
        
        /// 多部分表单数据请求体，支持混合普通字段和文件字段
        /// - Parameters:
        ///   - normals: 普通表单字段字典
        ///   - files: 文件上传模型数组
        ///   会自动设置 Content-Type 为 "multipart/form-data" 并生成正确的边界标识
        /// - NOTE: 该格式仅用于 `HTTP.uploadRequest` 方法
        case multipart(normals: [String: String], files: [UploadFileModel])
        
        /// 文件数据请求体
        /// - Parameter data: 文件的二进制数据内容
        /// - NOTE:
        ///   1. 不会自动设置 Content-Type
        ///   2. 该格式仅用于 `HTTP.uploadRequest` 方法
        case fileData(_ data: Data)
        
        /// 本地文件 URL 请求体
        /// - Parameter url: 本地文件 URL 地址
        /// - NOTE:
        ///   1. 不会自动设置 Content-Type
        ///   2. 该格式仅用于 `HTTP.uploadRequest` 方法
        case fileURL(_ url: URL)
        
        /// 获取请求体对应的参数字典
        /// 返回 nil 表示不进行编码操作或者有其他特殊处理
        fileprivate var params: Parameters? {
            switch self {
            case .none:
                nil
            case .binary:
                nil
            case .plain:
                nil
            case .json(let params):
                params
            case .form(let params):
                params
            case .multipart:
                nil
            case .fileData:
                nil
            case .fileURL:
                nil
            }
        }
        
        /// 获取请求体对应的参数编码器
        fileprivate var encoding: ParameterEncoding {
            switch self {
            case .none:
                URLEncoding.default
            case .binary(let data, let mimeType):
                BinaryParameterEncoding(data: data, mimeType: mimeType)
            case .plain(let text, let mimeType):
                PlainParameterEncoding(text: text, mimeType: mimeType)
            case .json:
                JSONEncoding.default
            case .form:
                URLEncoding.httpBody
            case .multipart:
                URLEncoding.default
            case .fileData:
                URLEncoding.default
            case .fileURL:
                URLEncoding.default
            }
        }
        
        /// 二进制数据参数编码器
        fileprivate struct BinaryParameterEncoding: ParameterEncoding {
            let data: Data
            let mimeType: String?
            func encode(_ urlRequest: any URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                // 设置 Content-Type 头部（如果提供了 MIME 类型）
                if let mimeType {
                    request.headers.update(.contentType(mimeType))
                }
                request.httpBody = data
                return request
            }
        }
        
        /// 纯文本参数编码器
        fileprivate struct PlainParameterEncoding: ParameterEncoding {
            let text: String
            let mimeType: String?
            func encode(_ urlRequest: any URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                // 设置 Content-Type 头部（如果提供了 MIME 类型）
                if let mimeType {
                    request.headers.update(.contentType(mimeType))
                }
                request.httpBody = text.data(using: .utf8)
                return request
            }
        }
        
        /// 将多部分表单数据添加到 MultipartFormData 对象中
        fileprivate func append(to formData: MultipartFormData) {
            guard case .multipart(let normals, let files) = self else { return }
            // 添加普通表单字段
            normals.forEach { key, value in
                formData.append(value.data(using: .utf8)!, withName: key)
            }
            // 添加文件表单数据
            files.forEach { file in
                switch file {
                case .fileData(let data, name: let name, fileName: let fileName, mimeType: let mimeType):
                    formData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
                case .fileURL(let url, name: let name, fileName: let fileName, mimeType: let mimeType):
                    formData.append(url, withName: name, fileName: fileName, mimeType: mimeType)
                }
            }
        }
        
    }
    
    /// 文件上传模型，支持从 Data 或 URL 上传文件
    enum UploadFileModel {
        /// 从 Data 对象上传文件
        case fileData(_ data: Data, name: String, fileName: String? = nil, mimeType: String? = nil)
        /// 从文件 URL 上传文件
        case fileURL(_ url: URL, name: String, fileName: String, mimeType: String)
    }
    
    /// 设置文件下载目标位置的闭包类型
    typealias DownloadFileDestination = Alamofire.DownloadRequest.Destination
   
    /// 修改请求的闭包类型，可用于自定义请求配置
    typealias RequestModifier = Alamofire.Session.RequestModifier
    
    /// 数据任务类型
    typealias DataTask = Alamofire.DataRequest
   
    /// 上传任务类型
    typealias UploadTask = Alamofire.UploadRequest
   
    /// 下载任务类型
    typealias DownloadTask = Alamofire.DownloadRequest

}

private extension HTTP {
    
    static func logRequest(_ request: HTTPRequest, taskID: UUID) {
        #if DEBUG
        Debugger.printTaskRequest(request, taskID: taskID)
        Debugger.addTask(with: request, taskID: taskID)
        #endif
    }
    
    static func logResult(_ result: Result<HTTPResponse, HTTPError>, taskID: UUID) {
        #if DEBUG
        Debugger.printTaskResult(result, taskID: taskID)
        Debugger.updateTask(with: result, taskID: taskID)
        #endif
    }
    
}

// MARK: - debug

class Debugger {
    
    class Task {
        let id: UUID
        let date: Date
        let request: HTTPRequest
        init(id: UUID, date: Date, request: HTTPRequest) {
            self.id = id
            self.date = date
            self.request = request
        }
        var result: Result<HTTPResponse, HTTPError>?
    }
    
    private(set) static var tasks: [Task] = []
    
    static func addTask(with request: HTTPRequest, taskID: UUID) {
        let task = Task(id: taskID, date: Date(), request: request)
        tasks.append(task)
        if tasks.count > 100 { tasks.removeFirst(tasks.count-100)}
    }
    
    static func updateTask(with result: Result<HTTPResponse, HTTPError>, taskID: UUID) {
        let task = tasks.first { $0.id == taskID }
        task?.result = result
    }
    
    static func clearTasks() {
        tasks = []
    }
    
}

extension Debugger {
    
    static func printTaskRequest(_ request: HTTPRequest, taskID: UUID) {
        let id = {
            taskID.uuidString
        }()
        print("request id = \(id)")
        let line = {
            "\(request.method.rawValue) \(request.url)"
        }()
        print("request line = \(line)")
        let headers = {
            let headersData = try! JSONSerialization.data(withJSONObject: request.headers, options: .prettyPrinted)
            let headersString = String(data: headersData, encoding: .utf8)!
            return headersString
        }()
        print("request headers = \(headers)")
        let body = {
            switch request.body {
            case .none:
                return "null"
            case .binary:
                return "binary 数据"
            case .plain(let text, _):
                return text
            case .json(let params):
                let paramsData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                let paramsString = String(data: paramsData, encoding: .utf8)!
                return paramsString
            case .form(let params):
                let paramsList = params.keys.map { "\($0)=\(params[$0]!)" }
                let paramsString = paramsList.joined(separator: "&")
                return paramsString
            case .multipart(let normals, let files):
                var formDataList = normals
                files.forEach { file in
                    switch file {
                    case .fileData(_, let name, _, _):
                        formDataList[name] = "Data 方式上传的二进制数据"
                    case .fileURL(_, let name, _, _):
                        formDataList[name] = "URL 方式上传的二进制数据"
                    }
                }
                let paramsData = try! JSONSerialization.data(withJSONObject: formDataList, options: .prettyPrinted)
                let paramsString = String(data: paramsData, encoding: .utf8)!
                return paramsString
            case .fileData:
                return "Data 方式上传的二进制数据"
            case .fileURL(let fileURL):
                return "URL 方式上传的二进制数据：\(fileURL.absoluteString)"
            }
        }()
        print("request body = \(body)")
    }
    
    static func printTaskResult(_ result: Result<HTTPResponse, HTTPError>, taskID: UUID) {
        switch result {
        case .success(let response):
            let id = {
                taskID.uuidString
            }()
            print("response id = \(id)")
            let headers = {
                let headersData = try! JSONSerialization.data(withJSONObject: response.headers, options: .prettyPrinted)
                let headersString = String(data: headersData, encoding: .utf8)!
                return headersString
            }()
            print("response headers = \(headers)")
            let body = {
                guard let bodyData = response.body, !bodyData.isEmpty else { return "null" }
                if let jsonObject = try? JSONSerialization.jsonObject(with: bodyData, options: []) {
                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    return jsonString
                }
                if let text = String(data: bodyData, encoding: .utf8) {
                    return text
                }
                return "body 数据存在但无法转为 JSON 或者字符串"
            }()
            print("response body = \(body)")
        case .failure(let error):
            let id = {
                taskID.uuidString
            }()
            print("response id = \(id)")
            let error = {
                error.errorDescription ?? "alamofire 未返回错误描述"
            }()
            print("response error = \(error)")
        }
    }
    
}
