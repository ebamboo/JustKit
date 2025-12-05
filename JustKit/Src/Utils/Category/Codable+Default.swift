//
//  Created by 姚旭 on 2025/12/2.
//

import Foundation

extension KeyedDecodingContainer {
    
    func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        defalut: T
    ) throws -> T where T : Decodable {
        let value = try? decode(type, forKey: key)
        return value ?? defalut
    }
    
    func decodeIfPresent<T>(
        _ type: T.Type,
        forKey key: K,
        defalut: T?
    ) throws -> T? where T? : Decodable {
        let value = try? decodeIfPresent(type, forKey: key)
        return value ?? defalut
    }
    
}

extension Encodable {
    
    var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
    
    var jsonString: String? {
        jsonData.flatMap { data in
            String(data: data, encoding: .utf8)
        }
    }
    
    func asDictionary() -> [String: Any]? {
        jsonData.flatMap { data in
            try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        }
    }
    
}

extension Decodable {
    
    static func decode(from jsonData: Data) -> Self?  {
        return try? JSONDecoder().decode(self, from: jsonData)
    }
    
    static func decode(from jsonString: String) -> Self?  {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(self, from: jsonData)
    }
    
}
