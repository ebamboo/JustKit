//
//  Created by 姚旭 on 2022/8/7.
//

import Foundation

///
/// 自动取消句柄
///
/// ## 机制
/// 各类型通过 `store(on:)` 创建 cancellable 并存入 owner 的 `autoCancellables` 中，
/// 形成持有链：**owner → cancellables → closure → 清理逻辑**。
/// owner 释放时 cancellable 随之释放，`deinit` 触发清理（invalidate / removeObserver 等）。
///
/// ## 支持的类型
/// - `Timer` — owner 释放时调用 `invalidate()`
/// - `CADisplayLink` — owner 释放时调用 `invalidate()`
/// - `NSKeyValueObservation` — owner 释放时释放观察对象，观察自动取消
/// - 通知观察者（`NotificationCenter.addObserver(forName:...)`）— owner 释放时调用 `removeObserver(_:)`
/// - `ScriptMessageSubscription` — owner 释放时释放订阅对象，`deinit` 自动移除 handler
///
class AutoCancellable {
    
    private let cleanup: () -> Void
    
    init(cleanup: @escaping () -> Void) {
        self.cleanup = cleanup
    }
    
    deinit {
        cleanup()
    }
    
}

extension NSObject {
    
    private static var auto_cancellables_key: Void?
    
    /// owner 持有的所有自动取消句柄
    ///
    /// 各类型的 `store(on:)` 方法将 cancellable 追加到此数组中。
    /// owner 释放时数组随之释放，所有 cancellable 的 `deinit` 依次触发清理逻辑。
    var autoCancellables: [AutoCancellable] {
        get {
            objc_getAssociatedObject(self, &Self.auto_cancellables_key) as? [AutoCancellable] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.auto_cancellables_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
