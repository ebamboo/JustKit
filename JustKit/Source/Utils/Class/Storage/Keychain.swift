//
//  Created by 姚旭 on 2021/4/18.
//
//  Apple 关于 Keychain Services 的官方文档
//  https://developer.apple.com/documentation/security/keychain_services
//

import Foundation
import Security

/// Keychain Services Wrapper for Generic Passwords
///
/// 提供一组类型安全的静态方法，用于存取 Generic Passwords 类型的敏感数据，如密码、令牌、密钥等。
///
/// ```swift
/// // 保存密码
/// let password = "s3cretP@ss"
/// let data = Data(password.utf8)
/// try Keychain.setData(data, forAccount: "user@example.com", service: "com.app.auth")
///
/// // 读取密码
/// if let data = try Keychain.data(forAccount: "user@example.com", service: "com.app.auth"),
///    let password = String(data: data, encoding: .utf8) {
///     print(password)
/// }
/// ```
///
/// - Important: Generic Password 的复合主键由以下属性组成：
///
///   - `kSecAttrAccount`
///   - `kSecAttrService`
///   - `kSecAttrAccessGroup`
///   - `kSecAttrSynchronizable`
///
///   所有主键属性值均相同的两个条目被视为同一条目，重复添加将产生 `errSecDuplicateItem` 错误。
public enum Keychain {
    
    /// 读取指定账号对应的密码数据。
    ///
    /// - Parameters:
    ///   - account: 账户标识。
    ///   - service: 服务标识。
    ///   - accessGroup: 访问组，`nil` 表示不限定。
    ///   - synchronizable: 是否为可同步条目。
    /// - Returns: 匹配条目的密码数据。无匹配条目时返回 `nil`。
    /// - Throws: ``KeychainError``。
    public static func data(
        forAccount account: String,
        service: String,
        accessGroup: String? = nil,
        synchronizable: Bool = false
    ) throws(KeychainError) -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: synchronizable,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecItemNotFound:
            return nil
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidDataFormat
            }
            return data
        default:
            throw KeychainError.operationFailed(status: status)
        }
    }
    
    /// 保存指定账号对应的密码数据。
    ///
    /// - Parameters:
    ///   - data: 密码数据。
    ///   - accessible: 访问策略。
    ///     当为 `nil` 时，更新操作不变更该属性，新增操作默认使用 ``.whenUnlocked``。
    ///   - account: 账户标识。
    ///   - service: 服务标识。
    ///   - accessGroup: 访问组。
    ///     当为 `nil` 时，更新操作匹配所有可访问组，新增操作使用系统默认访问组。
    ///   - synchronizable: 是否为可同步条目。
    /// - Throws: ``KeychainError``。
    ///   若 `synchronizable` 为 `true` 且 `accessible` 为 `ThisDeviceOnly` 级别，则参数无效，抛出错误。
    public static func setData(
        _ data: Data,
        accessible: Accessibility? = nil,
        forAccount account: String,
        service: String,
        accessGroup: String? = nil,
        synchronizable: Bool = false
    ) throws(KeychainError) {
        if synchronizable, let accessible, accessible.isThisDeviceOnly {
            throw KeychainError.operationFailed(status: errSecParam)
        }
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: synchronizable
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        var attributes: [String: Any] = [kSecValueData as String: data]
        if let accessible = accessible {
            attributes[kSecAttrAccessible as String] = accessible.secValue
        }
        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        switch updateStatus {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = (accessible ?? .whenUnlocked).secValue
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
    
    /// 读取指定服务下符合条件的条目。
    ///
    /// - Parameters:
    ///   - service: 服务标识。
    ///   - accessGroup: 访问组，`nil` 表示不限定。
    ///   - synchronizable: 是否为可同步条目，`nil` 表示不限定。
    /// - Returns: 匹配的条目列表。无匹配条目时返回空数组。自动过滤无效条目。返回顺序未定义。
    /// - Throws: ``KeychainError``。
    ///
    /// - Note:
    ///   本方法仅返回匹配条目的元信息。
    ///   对于 Generic Password 和 Internet Password 条目，
    ///   Apple 不允许在使用 `kSecMatchLimitAll` 时同时请求 `kSecReturnData`。
    ///   这是因为读取每个密码数据都可能触发额外的身份验证。
    ///   如需读取密码数据，请使用 ``data(forAccount:service:accessGroup:synchronizable:)`` 逐条获取。
    public static func items(
        forService service: String,
        accessGroup: String? = nil,
        synchronizable: Bool? = nil
    ) throws(KeychainError) -> [Item] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: synchronizable ?? kSecAttrSynchronizableAny,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecItemNotFound:
            return []
        case errSecSuccess:
            guard let list = result as? [[String: Any]] else {
                throw KeychainError.invalidDataFormat
            }
            return list.compactMap { info in
                guard
                    let accessGroup = info[kSecAttrAccessGroup as String] as? String,
                    let service = info[kSecAttrService as String] as? String,
                    let account = info[kSecAttrAccount as String] as? String,
                    let synchronizable = info[kSecAttrSynchronizable as String] as? Bool,
                    let secAccessible = info[kSecAttrAccessible as String] as? String,
                    let accessible = Accessibility(secValue: secAccessible as CFString)
                else {
                    return nil
                }
                let creationDate = info[kSecAttrCreationDate as String] as? Date
                let modificationDate = info[kSecAttrModificationDate as String] as? Date
                return Item(
                    accessGroup: accessGroup,
                    service: service,
                    account: account,
                    synchronizable: synchronizable,
                    accessible: accessible,
                    creationDate: creationDate,
                    modificationDate: modificationDate
                )
            }
        default:
            throw KeychainError.operationFailed(status: status)
        }
    }
    
    /// 删除指定服务下符合条件的条目。
    ///
    /// - Parameters:
    ///   - service: 服务标识。
    ///   - account: 账户标识，`nil` 表示不限定。
    ///   - accessGroup: 访问组，`nil` 表示不限定。
    ///   - synchronizable: 是否为可同步条目，`nil` 表示不限定。
    /// - Throws: ``KeychainError``。无匹配条目时视为成功，不会抛出错误。
    public static func deleteItems(
        forService service: String,
        account: String? = nil,
        accessGroup: String? = nil,
        synchronizable: Bool? = nil
    ) throws(KeychainError) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: synchronizable ?? kSecAttrSynchronizableAny
        ]
        if let account = account {
            query[kSecAttrAccount as String] = account
        }
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecItemNotFound || status == errSecSuccess else {
            throw KeychainError.operationFailed(status: status)
        }
    }
    
}

public extension Keychain {
    
    struct Item {
        public let accessGroup: String
        public let service: String
        public let account: String
        public let synchronizable: Bool
        
        public let accessible: Accessibility
        public let creationDate: Date?
        public let modificationDate: Date?
    }
    
    enum KeychainError: Error {
        case invalidDataFormat
        case operationFailed(status: Int32)
    }
    
    enum Accessibility {
        case whenUnlocked
        case afterFirstUnlock
        case whenPasscodeSetThisDeviceOnly
        case whenUnlockedThisDeviceOnly
        case afterFirstUnlockThisDeviceOnly
        fileprivate init?(secValue: CFString) {
            switch secValue {
            case kSecAttrAccessibleWhenUnlocked:
                self = .whenUnlocked
            case kSecAttrAccessibleAfterFirstUnlock:
                self = .afterFirstUnlock
            case kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly:
                self = .whenPasscodeSetThisDeviceOnly
            case kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
                self = .whenUnlockedThisDeviceOnly
            case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
                self = .afterFirstUnlockThisDeviceOnly
            default:
                return nil
            }
        }
        fileprivate var secValue: CFString {
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
        fileprivate var isThisDeviceOnly: Bool {
            switch self {
            case .whenPasscodeSetThisDeviceOnly,
                 .whenUnlockedThisDeviceOnly,
                 .afterFirstUnlockThisDeviceOnly:
                return true
            case .whenUnlocked,
                 .afterFirstUnlock:
                return false
            }
        }
    }
    
}
