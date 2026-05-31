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
/// ## 关键说明
///
/// Keychain 中 Generic Password（`kSecClassGenericPassword`）类型数据主要通过以下属性进行标识：
///
/// - `kSecAttrService`：业务域标识，用于隔离不同业务模块的数据。
/// - `kSecAttrAccount`：账号标识，用于区分同一服务下的不同用户。
/// - `kSecAttrAccessGroup`：Keychain Sharing 分组标识。
///
/// 对于 Generic Password 项，Apple 将 `kSecAttrService` 与 `kSecAttrAccount` 视为主要查询键（Primary Keys）。
///
/// 当多个应用通过 Keychain Sharing 共享数据时，访问组（Access Group）、服务标识（Service）与账号标识（Account）必须保持一致。
///
/// 因此，`service` 应作为业务级命名空间使用，不建议直接使用 Bundle Identifier 作为默认值，以避免后续服务拆分、组件共享或数据迁移时受到限制。
public enum Keychain {
    
    /// Keychain 条目元数据。
    public struct Item {
        public let account: String
        public let synchronizable: Bool
    }
    
    /// Keychain 操作相关错误。
    public enum KeychainError: Error, LocalizedError {
        /// 返回的数据无法转换为预期类型。
        case invalidDataFormat
        /// Keychain API 调用失败，附带 `OSStatus` 状态码。
        case operationFailed(status: OSStatus)
        /// 错误信息描述。
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
    /// 带有 `ThisDeviceOnly` 后缀的级别会阻止条目随备份迁移至其他设备。
    public enum Accessibility {
        /// 设备解锁期间可访问。系统默认项。
        /// 设备锁定后不可读取。
        case whenUnlocked
        /// 设备重启后首次解锁完成即可访问。
        /// 即使随后设备再次锁定，后台任务仍可访问。
        case afterFirstUnlock
        /// 仅当设备设置了密码且解锁时可访问。
        /// 数据不会迁移到其他设备。
        /// - Note: 若用户移除设备密码，受此级别保护的条目将被系统自动删除。
        case whenPasscodeSetThisDeviceOnly
        /// 设备解锁期间可访问。
        /// 数据仅保存在当前设备，不参与备份和迁移。
        case whenUnlockedThisDeviceOnly
        /// 首次解锁后即可访问。
        /// 数据仅保存在当前设备，不参与备份和迁移。
        case afterFirstUnlockThisDeviceOnly
        /// 对应 `kSecAttrAccessible` 属性值。
        public var secValue: CFString {
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
        /// 判断当前访问策略是否为设备专属。
        public var isThisDeviceOnly: Bool {
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
    
    /// 条目查询范围。
    public enum SynchronizableScope {
        /// 仅匹配本地条目（默认）。
        case local
        /// 仅匹配同步条目。
        case synchronizable
        /// 对应 `kSecAttrSynchronizable` 属性值。
        public var secValue: CFBoolean {
            switch self {
            case .local: kCFBooleanFalse
            case .synchronizable: kCFBooleanTrue
            }
        }
    }
    
    /// 获取指定服务下的所有条目。
    ///
    /// - Parameters:
    ///   - service: 服务标识符。
    ///   - group: 访问组标识符，`nil` 表示不限定。
    ///   - scope: 查询范围，`nil` 表示不限定。
    /// - Returns: 匹配的条目列表。无匹配条目时返回空数组。返回顺序未定义。
    /// - Throws: ``KeychainError``。
    ///
    /// - Note:
    ///   Apple 不允许同时使用 `kSecMatchLimitAll` 与 `kSecReturnData`。
    ///   因此该方法仅返回条目元信息，不返回对应密码数据。
    ///   如需读取密码数据，请使用 ``data(for:service:group:scope:)``。
    public static func items(for service: String, group: String? = nil, scope: SynchronizableScope? = .local) throws -> [Item] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: scope?.secValue ?? kSecAttrSynchronizableAny,
            // 设置为 `kSecMatchLimitAll` 返回列表
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
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
            // 过滤异常条目
            return list.compactMap { info in
                // 解析失败视为异常条目
                guard let account = info[kSecAttrAccount as String] as? String else {
                    return nil
                }
                // 解析失败视为本地条目
                let synchronizable = info[kSecAttrSynchronizable as String] as? Bool ?? false
                return Item(account: account, synchronizable: synchronizable)
            }
        default:
            throw KeychainError.operationFailed(status: status)
        }
    }
    
    /// 获取指定账号对应的密码数据。
    ///
    /// - Parameters:
    ///   - account: 账号标识符。
    ///   - service: 服务标识符。
    ///   - group: 访问组标识符，`nil` 表示不限定。
    ///   - scope: 查询范围。
    /// - Returns: 匹配的条目关联的二进制数据；无匹配条目时返回 `nil`。
    /// - Throws: ``KeychainError``。
    public static func data(for account: String, service: String, group: String? = nil, scope: SynchronizableScope = .local) throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: scope.secValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
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
    
    /// 保存或更新指定账号的密码数据。
    ///
    /// 采用 update-or-add 策略：优先尝试更新已有条目，若不存在则新增。
    ///
    /// - Parameters:
    ///   - data: 要保存的二进制数据。
    ///   - account: 账号标识符。
    ///   - service: 服务标识符。
    ///   - group: 访问组标识符，`nil` 表示不限定。
    ///   - synchronizable: 是否将条目标记为可同步。
    ///   - accessible: 数据保护级别。当传入 `nil` 时，更新操作不变更现有级别，新增操作默认使用 ``.whenUnlocked``。
    /// - Throws: ``KeychainError``。
    ///
    /// - Important: `synchronizable = true` 与带 `ThisDeviceOnly` 后缀的 ``Accessibility`` 互斥。
    ///   若检测到此冲突，将抛出 `errSecParam` 错误。
    /// - Note: `kSecAttrAccessible` 属于条目元数据，可在更新时同步变更，无需删除后重建（有些版本要求必须同步修改 `kSecValueData`）。
    /// - Note: `SecItemAdd` 时若未指定 `account` 或指定为空串 `""`，Keychain 中该条目的 `kSecAttrAccount` 均存储为 `""`。
    public static func setData(
        _ data: Data,
        for account: String,
        service: String,
        group: String? = nil,
        synchronizable: Bool = false,
        accessible: Accessibility? = nil
    ) throws {
        // 同步条目不兼容 ThisDeviceOnly 级别的访问策略
        if synchronizable, let accessible, accessible.isThisDeviceOnly {
            throw KeychainError.operationFailed(status: errSecParam)
        }
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: synchronizable
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
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
        case errSecItemNotFound: // 条目不存在则新增条目
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
    
    /// 删除指定账号对应的条目。
    ///
    /// 无匹配条目时视为成功，不会抛出错误。
    ///
    /// - Parameters:
    ///   - account: 账号标识符。
    ///   - service: 服务标识符。
    ///   - group: 访问组标识符，`nil` 表示不限定。
    ///   - scope: 查询范围，`nil` 表示不限定。
    /// - Throws: ``KeychainError``。
    ///
    /// - Note: 本方法显式指定了 `account`，仅匹配该账号对应的条目。
    ///   若不指定 `account`，`SecItemDelete` 将删除 `service` 下的所有条目——
    ///   这正是 ``deleteAllItems(for:group:scope:)`` 的行为。
    public static func deleteItem(for account: String, service: String, group: String? = nil, scope: SynchronizableScope? = .local) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: scope?.secValue ?? kSecAttrSynchronizableAny
        ]
        if let group = group {
            query[kSecAttrAccessGroup as String] = group
        }
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecItemNotFound || status == errSecSuccess else {
            throw KeychainError.operationFailed(status: status)
        }
    }
    
    /// 删除指定服务下的所有条目。
    ///
    /// 无匹配条目时视为成功，不会抛出错误。
    ///
    /// - Parameters:
    ///   - service: 服务标识符。
    ///   - group: 访问组标识符，`nil` 表示不限定。
    ///   - scope: 查询范围，`nil` 表示不限定。
    /// - Throws: ``KeychainError``。
    ///
    /// - Important: 此操作不可逆，调用前请确认意图。
    public static func deleteAllItems(for service: String, group: String? = nil, scope: SynchronizableScope? = .local) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrSynchronizable as String: scope?.secValue ?? kSecAttrSynchronizableAny
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
