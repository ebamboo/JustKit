//
//  Created by 姚旭 on 2025/12/2.
//

import Foundation

/// 为 KeyedDecodingContainer 提供带默认值的解码方法
/// 字段缺失或类型不匹配时返回默认值而非抛出错误
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
