//
//  Created by 姚旭 on 2023/12/15.
//
//  根据具体的项目约定，解析返回数据
//

import HandyJSON

struct BusinessBody<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?
}
extension BusinessBody {
    enum CodingKeys: CodingKey {
        case code
        case message
        case data
    }
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<BusinessBody<T>.CodingKeys> = try decoder.container(keyedBy: BusinessBody<T>.CodingKeys.self)
        self.code = try container.decode(Int.self, forKey: BusinessBody<T>.CodingKeys.code)
        self.message = try? container.decodeIfPresent(String.self, forKey: BusinessBody<T>.CodingKeys.message)
        self.data = try? container.decodeIfPresent(T.self, forKey: BusinessBody<T>.CodingKeys.data)
    }
}

enum BusinessError: Error {
    case business(message: String)
    case decoding
    case network(error: HTTPError)
}
extension BusinessError {
    var toast: String {
        switch self {
        case .business(let message):
            return message
        case .decoding:
            return "数据解析失败"
        case .network(let error):
            return error.errorDescription ?? "未知网络库错误"
        }
    }
}

extension HTTP {
    
    static func dataRequestForBody<Payload: Decodable>(
        _ type: Payload.Type,
        _ request: HTTPRequest,
        requestModifier: RequestModifier? = nil,
        completion: @escaping (_ result: Result<BusinessBody<Payload>, BusinessError>) -> Void
    ) {
        dataRequest(request, requestModifier: requestModifier) { result in
            switch result {
            case .success(let response):
                guard let jsonData = response.body, !jsonData.isEmpty else {
                    completion(.failure(.decoding))
                    return
                }
                do {
                    let model = try JSONDecoder().decode(BusinessBody<Payload>.self, from: jsonData)
                    completion(.success(model))
                } catch {
                    completion(.failure(.decoding))
                }
            case .failure(let error):
                completion(.failure(.network(error: error)))
            }
        }
    }
    
    static func dataRequestForPayload<Payload: Decodable>(
        _ type: Payload.Type,
        _ request: HTTPRequest,
        requestModifier: RequestModifier? = nil,
        completion: @escaping (_ result: Result<Payload, BusinessError>) -> Void
    ) {
        dataRequest(request, requestModifier: requestModifier) { result in
            switch result {
            case .success(let response):
                guard let jsonData = response.body, !jsonData.isEmpty else {
                    completion(.failure(.decoding))
                    return
                }
                do {
                    let model = try JSONDecoder().decode(BusinessBody<Payload>.self, from: jsonData)
                    if model.code == 200, let data = model.data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.business(message: model.message ?? "服务器未返回错误说明")))
                    }
                } catch {
                    completion(.failure(.decoding))
                }
            case .failure(let error):
                completion(.failure(.network(error: error)))
            }
        }
    }
    
}



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
