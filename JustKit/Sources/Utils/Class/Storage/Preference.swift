//
//  Created by 姚旭 on 2025/11/26.
//

import Foundation

/// 基于 `UserDefaults.standard` 的属性包装器，将属性的读写映射为对指定 key 的取存。
///
/// ```swift
/// enum AppPreference {
///     /// 是否首次启动
///     @Preference(key: "isFirstLaunch")
///     static var isFirstLaunch: Bool?
///     /// 上次运行的版本号
///     @Preference(key: "lastVersionCode")
///     static var lastVersionCode: String?
///     /// 登录凭证
///     @Preference(key: "userToken")
///     static var userToken: String?
/// }
/// ```
@propertyWrapper
public struct Preference<Value> {
    public let key: String
    public init(key: String) {
        self.key = key
    }
    public var wrappedValue: Value? {
        get {
            UserDefaults.standard.object(forKey: key) as? Value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
