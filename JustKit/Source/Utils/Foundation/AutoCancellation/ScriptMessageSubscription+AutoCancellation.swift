//
//  Created by 姚旭 on 2022/8/7.
//

import WebKit

// MARK: - ScriptMessageSubscription

/// ScriptMessage handler 的订阅对象
///
/// 行为参考 `NSKeyValueObservation`：释放即取消订阅。
/// 必须通过 `store(on:)` 或手动持有来管理生命周期，否则 handler 会立即被移除。
///
/// ## 用法
/// ```swift
/// // 方式一：存储到 owner 生命周期
/// contentController
///     .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
///         self?.handleBridgeMessage(message)
///     }
///     .store(on: self)
///
/// // 方式二：手动持有
/// self.subscription = contentController
///     .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
///         self?.handleBridgeMessage(message)
///     }
/// ```
/// 
public class ScriptMessageSubscription {
    
    /// 注册 handler 的 UserContentController（弱引用，避免循环持有）
    public weak private(set) var userContentController: WKUserContentController?
    
    /// 注册时使用的消息名称
    public let name: String
    
    init(userContentController: WKUserContentController, name: String) {
        self.userContentController = userContentController
        self.name = name
    }
    
    deinit {
        userContentController?.removeScriptMessageHandler(forName: name)
    }
    
}

// MARK: - 闭包注册

public extension WKUserContentController {
    
    /// 以闭包形式注册 ScriptMessage handler
    ///
    /// - Parameters:
    ///   - name: 消息名称，对应 JS 端 `window.webkit.messageHandlers.<name>.postMessage(...)`
    ///   - handler: 收到消息时的回调；通过 `message.body` 获取 JS 传递的数据
    /// - Returns: 订阅对象；调用其 `store(on:)` 实现自动生命周期管理
    func addScriptMessageHandler(
        for name: String,
        _ handler: @escaping (_ message: WKScriptMessage) -> Void
    ) -> ScriptMessageSubscription {
        add(ScriptMessageHandlerProxy(handler), name: name)
        return ScriptMessageSubscription(userContentController: self, name: name)
    }
    
    /// 遵守 WKScriptMessageHandler 协议的代理对象，将协议回调转发给闭包
    private class ScriptMessageHandlerProxy: NSObject, WKScriptMessageHandler {
        
        let handler: (_ message: WKScriptMessage) -> Void
        
        init(_ handler: @escaping (_ message: WKScriptMessage) -> Void) {
            self.handler = handler
        }
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            handler(message)
        }
        
    }
    
}

// MARK: - 自动取消

public extension ScriptMessageSubscription {
    
    /// 将 handler 的生命周期存储到 owner
    ///
    /// owner 释放时 subscription 随之释放，`deinit` 自动移除 handler。
    ///
    /// - Note: 闭包**强捕获** self（ScriptMessageSubscription）。
    ///   与 Timer、CADisplayLink、通知观察者不同（它们由 RunLoop 或 NotificationCenter 外部持有），
    ///   ScriptMessageSubscription 没有外部持有者，
    ///   若使用 `[weak self]` 则订阅对象会在 `store(on:)` 返回后立即释放，
    ///   触发 deinit 导致 handler 被立即移除。
    ///   强捕获使持有链为：owner → token → closure → ScriptMessageSubscription，
    ///   owner 释放时链路断开，subscription 释放并自动取消订阅。
    func store(on owner: NSObject) {
        // 强捕获 self：闭包持有 subscription，确保订阅在 owner 存活期间有效
        let token = AutoCancellationToken { _ = self }
        owner.autoCancellationTokens.append(token)
    }
    
}
