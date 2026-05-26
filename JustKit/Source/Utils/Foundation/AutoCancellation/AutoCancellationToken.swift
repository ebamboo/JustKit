//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

/// 自动取消令牌
///
/// 通用的生命周期管理工具，在自身 deinit 时自动执行清理闭包。
/// 将令牌存入 owner 的 `autoCancellationTokens` 关联对象中，
/// owner 释放时令牌随之释放，触发清理逻辑。
class AutoCancellationToken {
    
    private let cleanup: () -> Void
    
    init(cleanup: @escaping () -> Void) {
        self.cleanup = cleanup
    }
    
    deinit {
        cleanup()
    }
    
}

// MARK: - 关联对象存储

extension NSObject {
    
    private static var auto_cancellation_tokens_key: Void?
    
    var autoCancellationTokens: [AutoCancellationToken] {
        get {
            objc_getAssociatedObject(self, &Self.auto_cancellation_tokens_key) as? [AutoCancellationToken] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.auto_cancellation_tokens_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
