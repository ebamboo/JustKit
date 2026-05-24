//
//  Created by 姚旭 on 2025/9/30.
//

import Foundation
import Combine

public extension NSObject {
    
    /// 一般用于管理各种订阅
    /// 使用示例：`.store(in: &objc_cancellables)`
    ///
    /// 注意事项：
    /// 1. 内部使用 OBJC_ASSOCIATION_RETAIN_NONATOMIC，非线程安全；应确保在主线程操作
    /// 2. 值类型特性，不要拷贝到局部变量再操作（修改的是副本，不会写回关联对象），始终直接使用 `&objc_cancellables`
    var objc_cancellables: Set<AnyCancellable> {
        get {
            objc_getAssociatedObject(self, &Self.objc_cancellables_key) as? Set<AnyCancellable> ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.objc_cancellables_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private extension NSObject {
    
    static var objc_cancellables_key: Void?
    
}
