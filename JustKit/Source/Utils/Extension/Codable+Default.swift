//
//  Created by 姚旭 on 2025/12/2.
//

import Foundation

///
/// 为 KeyedDecodingContainer 提供带默认值的解码方法
/// 字段缺失或类型不匹配时返回默认值而非抛出错误
///
public extension KeyedDecodingContainer {
    
    /// 解码指定 key 的值，失败时返回 defaultValue
    func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key,
        defaultValue: T
    ) -> T where T : Decodable {
        let value = try? decode(type, forKey: key)
        return value ?? defaultValue
    }
    
    /// 解码指定 key 的可选值，失败时返回 defaultValue（可为 nil）
    func decodeIfPresent<T>(
        _ type: T.Type,
        forKey key: K,
        defaultValue: T?
    ) -> T? where T : Decodable {
        let value = try? decodeIfPresent(type, forKey: key)
        return value ?? defaultValue
    }
    
}

///
/// 将 Encodable 对象快速转为 Data / JSON 字符串 / 字典
///
public extension Encodable {
    
    /// 编码为 JSON Data
    var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
    
    /// 编码为 JSON 字符串（UTF-8）
    var jsonString: String? {
        jsonData.flatMap { data in
            String(data: data, encoding: .utf8)
        }
    }
    
    /// 编码为 [String: Any] 字典，适用于需要字典形式参数的场景
    func asDictionary() -> [String: Any]? {
        jsonData.flatMap { data in
            try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        }
    }
    
}

///
/// 从 JSON Data / JSON String 直接解码为模型对象
///
public extension Decodable {
    
    /// 从 JSON Data 解码，失败返回 nil
    static func decode(from jsonData: Data) -> Self? {
        return try? JSONDecoder().decode(self, from: jsonData)
    }
    
    /// 从 JSON 字符串（UTF-8）解码，失败返回 nil
    static func decode(from jsonString: String) -> Self? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(self, from: jsonData)
    }
    
}
