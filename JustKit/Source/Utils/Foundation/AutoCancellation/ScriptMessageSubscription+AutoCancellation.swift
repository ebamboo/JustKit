//
//  Created by 姚旭 on 2022/8/7.
//

import WebKit

// MARK: - 自动取消

public extension ScriptMessageSubscription {
    
    /// 将 handler 的生命周期存储到 owner
    ///
    /// owner 释放时 subscription 随之释放，`deinit` 自动移除 handler。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// - Note: 闭包**强捕获** self（ScriptMessageSubscription）。
    ///   与 Timer、CADisplayLink、通知观察者不同（它们由 RunLoop 或 NotificationCenter 外部持有），
    ///   ScriptMessageSubscription 没有外部持有者，
    ///   若使用 `[weak self]` 则订阅对象会在 `store(on:)` 返回后立即释放，
    ///   触发 deinit 导致 handler 被立即移除。
    ///   强捕获使持有链为：owner → token → closure → ScriptMessageSubscription，
    ///   owner 释放时链路断开，subscription 释放并自动取消订阅。
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有 `ScriptMessageSubscription`，
    /// 释放即自动取消订阅（deinit 中移除 handler）：
    /// ```swift
    /// // 手动管理
    /// self.subscription = contentController
    ///     .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
    ///         self?.handleBridgeMessage(message)
    ///     }
    /// // 需要停止时
    /// self.subscription = nil  // 释放即取消
    /// ```
    func store(on owner: NSObject) {
        // 强捕获 self：闭包持有 subscription，确保订阅在 owner 存活期间有效
        let token = AutoCancellationToken { _ = self }
        owner.autoCancellationTokens.append(token)
    }
    
}
