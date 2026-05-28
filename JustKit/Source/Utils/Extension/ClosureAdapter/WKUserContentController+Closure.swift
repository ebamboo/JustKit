//
//  Created by 姚旭 on 2026/5/28.
//

import WebKit

///
/// 为 `WKUserContentController` 提供基于闭包的消息处理，替代传统的 `WKScriptMessageHandler` 协议代理模式。
///
/// 支持按 name 注册多个 handler；返回的 `ScriptMessageSubscription` 释放时自动取消订阅。
///
public extension WKUserContentController {
    
    /// 以闭包形式注册 ScriptMessage handler。
    ///
    /// - Parameters:
    ///   - name: 消息名称，对应 JS 端 `window.webkit.messageHandlers.<name>.postMessage(...)`。
    ///   - handler: 收到消息时的回调；通过 `message.body` 获取 JS 传递的数据。
    /// - Returns: 订阅对象；释放即自动取消订阅。
    ///
    /// - Important: `ScriptMessageSubscription` 没有外部持有者，
    ///   必须持有返回的订阅对象，否则订阅会立即被取消。
    ///
    /// - Note: 生命周期管理有两种方式：
    ///
    ///   **手动管理** — 自行持有 subscription，置 nil 即取消：
    ///   ```swift
    ///   self.subscription = contentController
    ///       .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
    ///           self?.handleBridgeMessage(message)
    ///       }
    ///   // 需要停止时
    ///   self.subscription = nil  // 释放即取消
    ///   ```
    ///
    ///   **自动管理** — 通过 `store(on:)` 将生命周期绑定到 owner，owner 释放时自动取消订阅：
    ///   ```swift
    ///   contentController
    ///       .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
    ///           self?.handleBridgeMessage(message)
    ///       }
    ///       .store(on: self)
    ///   ```
    func addScriptMessageHandler(
        for name: String,
        _ handler: @escaping (_ message: WKScriptMessage) -> Void
    ) -> ScriptMessageSubscription {
        add(ClosureProxy(handler), name: name)
        return ScriptMessageSubscription(userContentController: self, name: name)
    }
    
}

///
/// ScriptMessage handler 的订阅对象
///
/// 行为参考 `NSKeyValueObservation`：释放即取消订阅。
///
public class ScriptMessageSubscription {
    
    public weak private(set) var userContentController: WKUserContentController?
    public let name: String
    init(userContentController: WKUserContentController, name: String) {
        self.userContentController = userContentController
        self.name = name
    }
    deinit {
        userContentController?.removeScriptMessageHandler(forName: name)
    }
    
}

private extension WKUserContentController {
    
    /// 遵守 WKScriptMessageHandler 协议的代理对象，将协议回调转发给闭包
    class ClosureProxy: NSObject, WKScriptMessageHandler {
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
