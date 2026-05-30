//
//  Created by 姚旭 on 2021/4/18.
//
//  Apple 关于 Keychain 的官方文档
//  https://developer.apple.com/documentation/security/keychain_services
//

import Foundation

/// Keychain Services Wrapper for Generic Passwords
///
/// 本工具提供了一组类型安全的静态方法，用于存取 `kSecClassGenericPassword` 类型的敏感数据，如密码、令牌、密钥等。
///
/// ## 概述
///
/// Keychain 中 Generic Password（kSecClassGenericPassword）类型数据主要通过以下属性进行标识：
///
/// - kSecAttrService：业务域标识，用于隔离不同业务模块的数据。
/// - kSecAttrAccount：账号标识，用于区分同一服务下的不同用户。
/// - kSecAttrAccessGroup：Keychain Sharing 分组标识。
///
/// 对于 Generic Password 项，Apple 将 kSecAttrService 与 kSecAttrAccount 视为主要查询键（Primary Keys）。
///
/// 当多个应用通过 Keychain Sharing 共享数据时，访问组（Access Group）、服务标识（Service）与账号标识（Account）必须保持一致。
///
/// 因此，service 应作为业务级命名空间使用，不建议直接使用 Bundle Identifier 作为默认值，以避免后续服务拆分、组件共享或数据迁移时受到限制。
///
/// ## 查询限制
///
/// You can’t combine the kSecReturnData and kSecMatchLimitAll options when copying password items, because copying each password item could require additional authentication.
///
/// 受此限制，批量查询账号时仅返回属性信息，不包含密码数据。如需读取所有密码，应先获取账号列表，再逐条读取。
///
/// - Note: `account` 参数的缺省行为。
///   - `SecItemAdd`：不指定 `account` 或指定为空串 `""`，Keychain 中该条目的 `kSecAttrAccount` 均存储为 `""`。
///   - `SecItemCopyMatching` / `SecItemDelete`：
///     不指定 `account` 时，操作范围为指定 `service` 下的**所有**条目；
///     指定为 `""` 时，仅操作 `account` 为 `""` 的条目。
public enum Keychain {
    
    public enum KeychainError: Error, LocalizedError {
        case invalidDataFormat
        case operationFailed(status: OSStatus)
        public var errorDescription: String? {
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
    
    public enum Accessibility {
        
        case whenUnlocked
        case afterFirstUnlock
        case whenPasscodeSetThisDeviceOnly
        case whenUnlockedThisDeviceOnly
        case afterFirstUnlockThisDeviceOnly
        
        public var value: CFString {
            switch self {
                
            case .whenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
                
            case .afterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock
                
            case .whenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
                
            case .whenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                
            case .afterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            }
        }
    }
    
    /// 读取所有账号
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
        guard let itemList = items as? [[String: Any]] else {
            throw KeychainError.invalidDataFormat
        }
        // 如果 Keychain 中存在无kSecAttrAccount的项（比如旧版本遗留数据、其他工具存储的项），调用 accounts 方法会直接抛出错误，导致无法获取任何有效账号。
        // 但方法的设计目标是「获取所有有效账号」，无账号的项本就应该被过滤，而非让整个调用失败。
        return itemList.compactMap { $0[kSecAttrAccount as String] as? String }
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
    ///
    /// - Parameters:
    ///   - data: 要保存的数据
    ///   - account: 用户唯一标识
    ///   - service: 服务唯一标识
    ///   - group: 钥匙串共享组
    ///   - accessible: 数据可访问性策略
    ///
    /// 保存逻辑：
    ///
    /// 1. 若 item 已存在，则执行 update
    /// 2. 若 item 不存在，则执行 add
    ///
    /// 注意：
    ///
    /// kSecAttrAccessible 属于 item 元数据，
    /// update 时也可以同步更新 accessibility。
    ///
    public static func setData(
        _ data: Data,
        for account: String,
        service: String,
        group: String? = nil,
        accessible: Accessibility? = nil // 当为 nil 时，更新操作不更新 kSecAttrAccessible，添加操作默认设置为 whenUnlocked
    ) throws {
        
        // 查询条件（主键）
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        
        // update 的属性
        var attributes: [String: Any] = [kSecValueData as String: data]
        if let accessible = accessible {
            attributes[kSecAttrAccessible as String] = accessible.value
        }
        
        // 先尝试更新
        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        switch updateStatus {
            
        case errSecSuccess:
            return
            
        case errSecItemNotFound:
            
            // 不存在则新增
            var newItem = query
            
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = (accessible ?? .whenUnlocked).value
            
            let addStatus = SecItemAdd(
                newItem as CFDictionary,
                nil
            )
            
            guard addStatus == errSecSuccess else {
                throw KeychainError.operationFailed(status: addStatus)
            }
            
        default:
            throw KeychainError.operationFailed(status: updateStatus)
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
    
}
