//
//  Created by 姚旭 on 2021/11/19.
//
//  可参考 Alamofire 中 `AuthenticationInterceptor` 实现自动刷新 Token 逻辑。
//  https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#authenticationinterceptor
//

import Alamofire

protocol HTTPRequest {
    
    /// HTTP 请求方法（GET、POST、PUT、DELETE 等）
    var method: HTTP.Method { get }
    
    /// HTTP 请求的完整 URL 地址（协议 + 域名 + 路径 + query + fragment）
    /// - Important: 框架不会对传入的字符串做任何编码、转义、解析或修改操作，请严格遵循与后端约定的 URL 格式和编码规范
    ///   - ✅ `"https://api.example.com/redirect?target=https%3A%2F%2Fwww.google.com%3Fq%3Dswift%26hl%3Dzh-CN"`
    ///   - ❌ `"https://api.example.com/redirect?target=https://www.google.com?q=swift&hl=zh-CN"`
    var url: String { get }
    
    /// HTTP 请求头部字段字典
    var headers: [String: String] { get }
    
    /// HTTP 请求体内容，支持多种数据格式
    var body: HTTP.Body { get }
    
}

struct HTTPResponse {
    
    /// HTTP 响应头部字段字典
    let headers: [String: String]
    
    /// HTTP 响应体数据，原始二进制格式
    /// - Note: 此字段为可选类型，因为某些响应可能没有主体（如 HEAD 请求或 204 No Content 响应）
    let body: Data?
    
}

typealias HTTPError = AFError

extension HTTP {
    
    /// 普通数据请求
    /// - Parameters:
    ///   - request: 遵循 HTTPRequest 协议的请求对象
    ///   - interceptor: 请求拦截器，可用于注入 token 或 token 过期后自动刷新并重新请求
    ///   - requestModifier: 请求修改器，可用于自定义请求
    ///   - completion: 完成回调，返回 HTTPResponse 或 HTTPError
    /// - Returns: 返回可管理的数据任务对象
    /// - Note: `request.body` 不能是   `.multipart`、`.fileData` 、 `.fileURL` 任一类型，否则 Release 模式下本次请求体为空
    @discardableResult
    static func dataRequest(
        _ request: HTTPRequest,
        interceptor: (any RequestInterceptor)? = nil,
        requestModifier: RequestModifier? = nil,
        completion: @escaping (_ result: Result<HTTPResponse, HTTPError>) -> Void
    ) -> DataTask {
        assert(
            {
                switch request.body {
                case .multipart, .fileData, .fileURL: false
                default: true }
            }(),
            "dataRequest 不支持 .multipart、.fileData、.fileURL 类型的 body"
        )
        let task = AF.request(
            request.url,
            method: request.method,
            parameters: request.body.params,
            encoding: request.body.encoding,
            headers: HTTPHeaders(request.headers),
            interceptor: interceptor,
            requestModifier: requestModifier
        )
        task.validate()
        task.response(queue: .main) { dataResponse in
            let result: Result<HTTPResponse, HTTPError>
            if let error = dataResponse.error {
                result = .failure(error)
            } else {
                let headers = dataResponse.response?.allHeaderFields as? [String: String] ?? [:]
                let body = dataResponse.data
                result = .success(.init(headers: headers, body: body))
            }
            completion(result)
        }
        return task
    }
    
    /// 文件上传请求
    /// - Parameters:
    ///   - request: 遵循 HTTPRequest 协议的请求对象
    ///   - interceptor: 请求拦截器，可用于注入 token 或 token 过期后自动刷新并重新请求
    ///   - requestModifier: 请求修改器，可用于自定义请求
    ///   - progress: 上传进度回调
    ///   - completion: 完成回调，返回 Body 或 HTTPError
    /// - Returns: 返回可管理的上传任务对象
    /// - Note: `request.body` 必须是  `.multipart`、`.fileData` 、 `.fileURL` 任一类型，否则 Release 模式下本次请求体为空
    @discardableResult
    static func uploadRequest(
        _ request: HTTPRequest,
        interceptor: (any RequestInterceptor)? = nil,
        requestModifier: RequestModifier? = nil,
        progress: @escaping (_ progress: Progress) -> Void = { _ in },
        completion: @escaping (_ result: Result<Data?, HTTPError>) -> Void
    ) -> UploadTask {
        assert(
            {
                switch request.body {
                case .multipart, .fileData, .fileURL: true
                default: false }
            }(),
            "uploadRequest 仅支持 .multipart、.fileData、.fileURL 类型的 body"
        )
        let task: UploadRequest
        switch request.body {
        case .fileData(let fileData):
            task = AF.upload(
                fileData,
                to: request.url,
                method: request.method,
                headers: HTTPHeaders(request.headers),
                interceptor: interceptor,
                requestModifier: requestModifier
            )
        case .fileURL(let fileURL):
            task = AF.upload(
                fileURL,
                to: request.url,
                method: request.method,
                headers: HTTPHeaders(request.headers),
                interceptor: interceptor,
                requestModifier: requestModifier
            )
        default:
            task = AF.upload(
                multipartFormData: { request.body.append(to: $0) },
                to: request.url,
                method: request.method,
                headers: HTTPHeaders(request.headers),
                interceptor: interceptor,
                requestModifier: requestModifier
            )
        }
        task.validate()
        task.uploadProgress(closure: progress)
        task.response(queue: .main) { uploadResponse in
            let result: Result<Data?, HTTPError>
            if let error = uploadResponse.error {
                result = .failure(error)
            } else {
                result = .success(uploadResponse.data)
            }
            completion(result)
        }
        return task
    }
    
    /// 文件下载请求
    /// - Parameters:
    ///   - request: 遵循 HTTPRequest 协议的请求对象
    ///   - destination: 文件下载目标位置
    ///   - interceptor: 请求拦截器，可用于注入 token 或 token 过期后自动刷新并重新请求
    ///   - requestModifier: 请求修改器，可用于自定义请求
    ///   - progress: 下载进度回调
    ///   - completion: 完成回调，返回 fileURL 或 HTTPError
    /// - Returns: 返回可管理的下载任务对象
    /// - Note:
    ///   1. 若成功则响应 body 为本地储存路径
    ///   2. `request.body` 不能是  `.multipart`、`.fileData` 、 `.fileURL` 任一类型，否则 Release 模式下本次请求体为空
    @discardableResult
    static func downloadRequest(
        _ request: HTTPRequest,
        to destination: DownloadFileDestination? = nil,
        interceptor: (any RequestInterceptor)? = nil,
        requestModifier: RequestModifier? = nil,
        progress: @escaping (_ progress: Progress) -> Void = { _ in },
        completion: @escaping (_ result: Result<URL?, HTTPError>) -> Void
    ) -> DownloadTask {
        assert(
            {
                switch request.body {
                case .multipart, .fileData, .fileURL: false
                default: true }
            }(),
            "downloadRequest 不支持 .multipart、.fileData、.fileURL 类型的 body"
        )
        let task = AF.download(
            request.url,
            method: request.method,
            parameters: request.body.params,
            encoding: request.body.encoding,
            headers: HTTPHeaders(request.headers),
            interceptor: interceptor,
            requestModifier: requestModifier,
            to: destination
        )
        task.validate()
        task.downloadProgress(closure: progress)
        task.response(queue: .main) { downloadResponse in
            let result: Result<URL?, HTTPError>
            if let error = downloadResponse.error {
                result = .failure(error)
            } else {
                result = .success(downloadResponse.fileURL)
            }
            completion(result)
        }
        return task
    }
    
}

enum HTTP {
    
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
        /// - Note: 该格式仅用于 `HTTP.uploadRequest` 方法
        case multipart(normals: [String: String], files: [UploadFileModel])
        
        /// 文件数据请求体
        /// - Parameter data: 文件的二进制数据内容
        /// - Note:
        ///   1. 不会自动设置 Content-Type
        ///   2. 该格式仅用于 `HTTP.uploadRequest` 方法
        case fileData(_ data: Data)
        
        /// 本地文件 URL 请求体
        /// - Parameter url: 本地文件 URL 地址
        /// - Note:
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
                request.httpBody = Data(text.utf8)
                return request
            }
        }
        
        /// 将多部分表单数据添加到 MultipartFormData 对象中
        fileprivate func append(to formData: MultipartFormData) {
            guard case .multipart(let normals, let files) = self else { return }
            // 添加普通表单字段
            normals.forEach { key, value in
                formData.append(Data(value.utf8), withName: key)
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
    
    /// 请求拦截器类型（协议），可用于自定义拦截配置
    typealias RequestInterceptor = Alamofire.RequestInterceptor
    
    /// 修改请求的闭包类型，可用于自定义请求配置
    typealias RequestModifier = Alamofire.Session.RequestModifier
    
    /// 数据任务类型
    typealias DataTask = Alamofire.DataRequest
    
    /// 上传任务类型
    typealias UploadTask = Alamofire.UploadRequest
    
    /// 下载任务类型
    typealias DownloadTask = Alamofire.DownloadRequest
    
}
