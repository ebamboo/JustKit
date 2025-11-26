//
//  Created by 姚旭 on 2025/11/26.
//

import Foundation

///
/// 这是一个属性包装器，用于管理通过 UserDefaults 存储的偏好设置
/// 使用方法如示例：
///

/*
extension UserDefaults {

    @Preference(name: "firstLaunch")
    static var firstLaunch: Bool?

    @Preference(name: "defaultModel")
    static var defaultModel: String?

}
*/

@propertyWrapper
struct Preference<Value> {
    let name: String
    var wrappedValue: Value? {
        get {
            UserDefaults.standard.object(forKey: name) as? Value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: name)
        }
    }
}
