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
public enum Keychain {
    
    public enum KeychainError: Error, LocalizedError {
        /// 返回的数据无法转换为预期类型。
        case invalidDataFormat
        /// Keychain API 调用失败，附带 `OSStatus` 状态码。
        case operationFailed(status: OSStatus)
        /// 错误信息描述
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
    
    /// Keychain 数据可访问性策略。对应 `kSecAttrAccessible` 属性。
    ///
    /// 带有 `ThisDeviceOnly` 后缀的级别会阻止条目随备份迁移至其他设备
    public enum Accessibility {
        /// 设备解锁期间可访问。系统默认项。
        /// 设备锁定后不可读取。
        case whenUnlocked
        /// 设备重启后首次解锁完成即可访问。
        /// 即使随后设备再次锁定，后台任务仍可访问。
        case afterFirstUnlock
        /// 仅当设备设置了密码且解锁时可访问。
        /// 数据不会迁移到其他设备。
        case whenPasscodeSetThisDeviceOnly
        /// 设备解锁期间可访问。
        /// 数据仅保存在当前设备，不参与备份和迁移。
        case whenUnlockedThisDeviceOnly
        /// 首次解锁后即可访问。
        /// 数据仅保存在当前设备，不参与备份和迁移。
        case afterFirstUnlockThisDeviceOnly
        /// 对应 `kSecAttrAccessible` 属性值
        public var value: CFString {
            switch self {
            case .whenUnlocked:
                kSecAttrAccessibleWhenUnlocked
            case .afterFirstUnlock:
                kSecAttrAccessibleAfterFirstUnlock
            case .whenPasscodeSetThisDeviceOnly:
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlockedThisDeviceOnly:
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            case .afterFirstUnlockThisDeviceOnly:
                kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
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
