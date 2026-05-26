//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

///
/// 自动取消令牌
///
/// 在自身 `deinit` 时执行清理闭包，将订阅/观察的生命周期绑定到 owner 对象上。
///
/// ## 机制
/// 各类型通过 `store(on:)` 创建令牌并存入 owner 的 `autoCancellationTokens` 中，
/// 形成持有链：**owner → tokens → closure → 清理逻辑**。
/// owner 释放时令牌随之释放，`deinit` 触发清理（invalidate / removeObserver 等）。
///
/// ## 支持的类型
/// - `Timer` — owner 释放时调用 `invalidate()`
/// - `CADisplayLink` — owner 释放时调用 `invalidate()`
/// - `NSKeyValueObservation` — owner 释放时释放观察对象，观察自动取消
/// - 通知观察者（`NotificationCenter.addObserver(forName:...)`）— owner 释放时调用 `removeObserver(_:)`
/// - `ScriptMessageSubscription` — owner 释放时释放订阅对象，`deinit` 自动移除 handler
///
/// ## 用法
/// ```swift
/// // 通过 store(on:) 绑定到 owner 生命周期
/// Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
///     self?.updateCountdown()
/// }.store(on: self)
/// ```
///
class AutoCancellationToken {
    
    private let cleanup: () -> Void
    
    init(cleanup: @escaping () -> Void) {
        self.cleanup = cleanup
    }
    
    deinit {
        cleanup()
    }
    
}

extension NSObject {
    
    private static var auto_cancellation_tokens_key: Void?
    
    /// owner 持有的所有自动取消令牌
    ///
    /// 各类型的 `store(on:)` 方法将令牌追加到此数组中。
    /// owner 释放时数组随之释放，所有令牌的 `deinit` 依次触发清理逻辑。
    var autoCancellationTokens: [AutoCancellationToken] {
        get {
            objc_getAssociatedObject(self, &Self.auto_cancellation_tokens_key) as? [AutoCancellationToken] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.auto_cancellation_tokens_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
