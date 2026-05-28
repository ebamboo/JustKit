//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

public extension Timer {
    
    /// 将 Timer 的生命周期存储到 owner
    ///
    /// - Parameters:
    ///   - owner: 生命周期的宿主，owner 释放时自动调用 `invalidate()`。
    ///   - installedThread: Timer 被安装（scheduled）到的 RunLoop 线程，默认 `.main`。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// ```swift
    /// // 自动管理 — 通过 store(on:installedThread:) 绑定到 owner 生命周期
    /// Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    ///     self?.updateCountdown()
    /// }.store(on: self)
    /// ```
    ///
    /// 若不使用 `store(on:installedThread:)` 自动管理，可手动持有 Timer 并在合适时机调用 `invalidate()`：
    /// ```swift
    /// // 手动管理
    /// self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    ///     self?.updateCountdown()
    /// }
    /// // 需要停止时
    /// self.timer?.invalidate()
    /// self.timer = nil
    /// ```
    func store(on owner: NSObject, installedThread: Thread = .main) {
        // 弱捕获 self：RunLoop 外部持有 Timer，即使闭包不强持有，Timer 仍存活直到被 invalidate
        let token = AutoCancellationToken { [weak self, weak installedThread] in
            guard let self, let installedThread else { return }
            // Timer 绑定 RunLoop，需在所属 RunLoop 线程 invalidate
            if Thread.current === installedThread {
                self.invalidate()
            } else {
                self.perform(#selector(Self.invalidate), on: installedThread, with: nil, waitUntilDone: false)
            }
        }
        owner.autoCancellationTokens.append(token)
    }
    
}
