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
