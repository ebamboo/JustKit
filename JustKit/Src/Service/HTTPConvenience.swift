//
//  Created by 姚旭 on 2023/12/15.
//
//  为特定项目在 HTTP 工具基础上封装的便利工具，和项目有强耦合关系
//  需根据具体的项目约定定义返回数据模型以及解析规则
//

import Foundation

struct BusinessBody<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?
}

enum BusinessError: Error {
    case business(message: String?)
    case decoding(reason: String)
    case underlying(error: HTTPError)

    var toast: String {
        switch self {
        case .business(let message):
            return message ?? "服务器未返回错误说明"
        case .decoding(let reason):
            return reason
        case .underlying(let error):
            return error.errorDescription ?? "网络工具库未返回错误说明"
        }
    }
}

extension HTTP {
    
    static func dataRequestForBody<Payload: Decodable>(
        _ type: Payload.Type,
        _ request: HTTPRequest,
        interceptor: (any RequestInterceptor)? = nil,
        requestModifier: RequestModifier? = nil,
        completion: @escaping (_ result: Result<BusinessBody<Payload>, BusinessError>) -> Void
    ) {
        dataRequest(request, interceptor: interceptor, requestModifier: requestModifier) { result in
            switch result {
            case .success(let response):
                guard let jsonData = response.body, !jsonData.isEmpty else {
                    completion(.failure(.decoding(reason: "响应数据为空")))
                    return
                }
                do {
                    let model = try JSONDecoder().decode(BusinessBody<Payload>.self, from: jsonData)
                    completion(.success(model))
                } catch {
                    completion(.failure(.decoding(reason: "响应数据格式异常")))
                }
            case .failure(let error):
                completion(.failure(.underlying(error: error)))
            }
        }
    }
    
    static func dataRequestForPayload<Payload: Decodable>(
        _ type: Payload.Type,
        _ request: HTTPRequest,
        interceptor: (any RequestInterceptor)? = nil,
        requestModifier: RequestModifier? = nil,
        completion: @escaping (_ result: Result<Payload, BusinessError>) -> Void
    ) {
        dataRequestForBody(type, request, interceptor: interceptor, requestModifier: requestModifier) { result in
            switch result {
            case .success(let body):
                if body.code == 200 {
                    if let data = body.data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.decoding(reason: "载荷数据为空")))
                    }
                } else {
                    completion(.failure(.business(message: body.message)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
