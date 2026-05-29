//
//  Created by 姚旭 on 2021/4/18.
//

import Foundation

///
/// 使用钥匙串管理账号和密码数据
/// 密码数据不仅仅指一个简单的字符串，还可以是一些其他敏感数据
///
/// kSecAttrAccessGroup 表示共享组唯一标识
/// kSecAttrService 表示服务唯一标识
/// kSecAttrAccount 一般用于表示用户唯一标识
/// 同一个开发者账号下多个 app 通过钥匙串共享数据时，以上三个参数必须相同。
/// 因此，共享组名称和服务名称要设置为一个有意义的名称，不可如网上所说的那样简单地把 service 设置为 bundle identifier。
///
/// Apple 关于 Keychain 的文档
/// https://developer.apple.com/documentation/security/keychain_services
///
/// 注意一：
/// 1. For generic passwords, the primary keys include kSecAttrAccount and kSecAttrService.
/// 对于 kSecClassGenericPassword 密码数据，主键包含 kSecAttrAccount 和 kSecAttrService
/// 2. You can’t combine the kSecReturnData and kSecMatchLimitAll options when copying password items, because copying each password item could require additional authentication. Instead, request a reference or persistent reference to the items, then request the data for only the specific passwords that you actually require.
/// 查询时不能同时使用 kSecReturnData 和 kSecMatchLimitAll，所以不能同时读取所有的 kSecAttrAccount 和 kSecValueData。基于此，可以先获取所有 accounts，再按需使用 account 读取密码数据（kSecValueData）
///
/// 注意二：
/// 调用 SecItemAdd 时， 不设置 kSecAttrAccount 或者设置 kSecAttrAccount 为 "" 等效 ------ Keychain 中存储为 ""
/// 调用 SecItemCopyMatching 或者 SecItemDelete 时，
/// 不设置 kSecAttrAccount 则操作对象为所有 kSecAttrService 为 service 的 items
/// 设置 kSecAttrAccount 为 "" 则操作对象为所有 kSecAttrService 为 service 且 kSecAttrAccount 为 "" 的 items
///
public enum Keychain {
    
    enum KeychainError: Error, LocalizedError {
        case invalidDataFormat
        case operationFailed(status: OSStatus)
        var errorDescription: String {
            switch self {
            case .invalidDataFormat:
                return "Invalid keychain data format"
            case .operationFailed(let status):
                if let msg = SecCopyErrorMessageString(status, nil) {
                    return msg as String
                }
                return "Keychain operation failed: \(status)"
            }
        }
    }
    
    /// 删除  kSecAttrService 为 service 且 kSecAttrAccount 为 account 的 item
    public static func deleteItem(for account: String, service: String, group: String? = nil) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecItemNotFound || status == errSecSuccess else {
            throw KeychainError.operationFailed(status: status)
        }
    }
    
    /// 删除 kSecAttrService 为 service 的所有 items
    public static func deleteAllItems(for service: String, group: String? = nil) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecItemNotFound || status == errSecSuccess else {
            throw KeychainError.operationFailed(status: status)
        }
    }
    
    /// 读取所有账号
    /// 若返回的列表为空，可能 errSecItemNotFound 或者 itemList.compactMap 结果为空
    /// 空的含义：调用 isEmpty 返回 true
    public static func accounts(for service: String, group: String? = nil) throws -> [String] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll, // 必须明确设置为 kSecMatchLimitAll，否则返回的 items 不为 [[String: Any]]
            kSecReturnAttributes as String: true
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        
        if status == errSecItemNotFound { return [] }
        guard status == errSecSuccess else { throw KeychainError.operationFailed(status: status) }
        guard let itemList = items as? [[String: Any]] else { throw KeychainError.invalidDataFormat }
        return try itemList.map {
            guard let account = $0[kSecAttrAccount as String] as? String else {
                throw KeychainError.invalidDataFormat
            }
            return account
        }
    }
    
    /// 读取数据
    public static func data(for account: String, service: String, group: String? = nil) throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne, // 主键为 service+account 因此最多存在一个（如果 Keychain 中已存在则无法再次添加）
            kSecReturnData as String: true
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw KeychainError.operationFailed(status: status) }
        guard let data = item as? Data else {
            throw KeychainError.invalidDataFormat
        }
        return data
    }
    
    /// 保存数据
    public static func saveData(_ data: Data, for account: String, service: String, group: String? = nil) throws {
        try deleteItem(for: account, service: service, group: group)
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else { throw KeychainError.operationFailed(status: status) }
    }
    
}
