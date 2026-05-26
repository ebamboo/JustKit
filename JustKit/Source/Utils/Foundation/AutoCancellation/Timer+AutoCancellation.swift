//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

// MARK: - 自动取消

public extension Timer {
    
    /// 将 Timer 的生命周期存储到 owner
    ///
    /// owner 释放时自动调用 `invalidate()`
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// - Note: 闭包**弱捕获** self（Timer）。
    ///   RunLoop 外部持有 Timer，即使闭包不强持有，Timer 仍存活直到被 invalidate。
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
    ///
    /// ## 示例
    /// ```swift
    /// Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    ///     self?.updateCountdown()
    /// }.store(on: self)
    /// ```
    func store(on owner: NSObject) {
        let token = AutoCancellationToken { [weak self] in
            self?.invalidate()
        }
        owner.autoCancellationTokens.append(token)
    }
    
}
