//
//  Created by 姚旭 on 2023/12/15.
//
//  根据具体的项目约定定义返回数据模型
//

import Foundation

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
