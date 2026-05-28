//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

public extension Timer {
    
    /// 将 Timer 的生命周期存储到 owner
    ///
    /// owner 释放时自动调用 `invalidate()`。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// ```swift
    /// // 自动管理 — 通过 store(on:) 绑定到 owner 生命周期
    /// Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    ///     self?.updateCountdown()
    /// }.store(on: self)
    /// ```
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有 Timer 并在合适时机调用 `invalidate()`：
    /// ```swift
    /// // 手动管理
    /// self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    ///     self?.updateCountdown()
    /// }
    /// // 需要停止时
    /// self.timer?.invalidate()
    /// self.timer = nil
    /// ```
    func store(on owner: NSObject) {
        // 弱捕获 self：RunLoop 外部持有 Timer，即使闭包不强持有，Timer 仍存活直到被 invalidate
        let token = AutoCancellationToken { [weak self] in
            self?.invalidate()
        }
        owner.autoCancellationTokens.append(token)
    }
    
}
