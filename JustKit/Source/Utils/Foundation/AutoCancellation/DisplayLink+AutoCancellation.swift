//
//  Created by 姚旭 on 2025/7/4.
//

import UIKit

public extension CADisplayLink {
    
    /// 将 CADisplayLink 的生命周期存储到 owner
    ///
    /// owner 释放时自动调用 `invalidate()`。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// ```swift
    /// // 自动管理 — 通过 store(on:) 绑定到 owner 生命周期
    /// let link = CADisplayLink { [weak self] link in
    ///     self?.update(link)
    /// }
    /// link.add(to: .main, forMode: .common)
    /// link.store(on: self)
    /// ```
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有 CADisplayLink 并在合适时机调用 `invalidate()`：
    /// ```swift
    /// // 手动管理
    /// self.displayLink = CADisplayLink { [weak self] link in
    ///     self?.update(link)
    /// }
    /// self.displayLink?.add(to: .main, forMode: .common)
    /// // 需要停止时
    /// self.displayLink?.invalidate()
    /// self.displayLink = nil
    /// ```
    func store(on owner: NSObject) {
        // 弱捕获 self：RunLoop 外部持有 CADisplayLink，即使闭包不强持有，DisplayLink 仍存活直到被 invalidate
        let token = AutoCancellationToken { [weak self] in
            self?.invalidate()
        }
        owner.autoCancellationTokens.append(token)
    }
    
}
