//
//  Created by 姚旭 on 2022/8/7.
//

import WebKit

public extension ScriptMessageSubscription {
    
    /// 将脚本消息订阅的生命周期存储到 owner
    ///
    /// owner 释放时 subscription 随之释放，`deinit` 自动移除 handler。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// ```swift
    /// // 自动管理 — 通过 store(on:) 绑定到 owner 生命周期
    /// contentController
    ///     .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
    ///         self?.handleBridgeMessage(message)
    ///     }
    ///     .store(on: self)
    /// ```
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有 `ScriptMessageSubscription`，
    /// 释放即自动取消订阅（`deinit` 中移除 handler）：
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
        // 强捕获 self：ScriptMessageSubscription 无外部持有者，闭包必须强引用以维持订阅在 owner 存活期间有效
        let token = AutoCancellationToken { _ = self }
        owner.autoCancellationTokens.append(token)
    }
    
}
