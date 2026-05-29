//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

public extension NSKeyValueObservation {
    
    /// 将 KVO 观察的生命周期存储到 owner
    ///
    /// owner 释放时观察自动取消。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// ```swift
    /// // 自动管理 — 通过 store(on:) 绑定到 owner 生命周期
    /// scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
    ///     self?.handleScroll(scrollView)
    /// }.store(on: self)
    /// ```
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有 `NSKeyValueObservation`，
    /// 释放即自动取消观察，也可主动调用 `invalidate()` 提前取消：
    /// ```swift
    /// // 手动管理
    /// self.observation = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
    ///     self?.handleScroll(scrollView)
    /// }
    /// // 需要停止时（二选一）
    /// self.observation?.invalidate()  // 主动取消
    /// self.observation = nil          // 释放即取消
    /// ```
    func store(on owner: NSObject) {
        // 强捕获 self：NSKeyValueObservation 无外部持有者，闭包必须强引用以维持观察在 owner 存活期间有效
        let cancellable = AutoCancellable { _ = self }
        owner.autoCancellables.append(cancellable)
    }
    
}
