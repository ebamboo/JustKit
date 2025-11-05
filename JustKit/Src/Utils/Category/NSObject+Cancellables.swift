//
//  Created by 姚旭 on 2025/9/30.
//

import Foundation
import Combine

public extension NSObject {
    
    /// 一般用于管理各种订阅
    /// 使用示例：`.store(in: &objc_cancellables)`
    var objc_cancellables: Set<AnyCancellable> {
        get {
            withUnsafePointer(to: &Self.objc_cancellables_key) { key in
                objc_getAssociatedObject(self, key) as? Set<AnyCancellable> ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.objc_cancellables_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}

private extension NSObject {
    
    static var objc_cancellables_key = "objc_cancellables_key"
    
}
