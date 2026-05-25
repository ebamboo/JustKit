//
//  Created by 姚旭 on 2022/8/7.
//

import WebKit

// MARK: - WKUserContentController Convenience

//
// 基于闭包的 WKScriptMessageHandler 便捷注册
//
// 将协议代理模式简化为闭包调用，并通过返回的 `ScriptMessageObservation` 令牌
// 自动管理 handler 的生命周期——令牌释放时自动移除对应的 handler。
//
// 用法：
//
//   // 1. 注册 handler，由 owner 管理生命周期（推荐）
//   contentController
//       .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
//           self?.handleBridgeMessage(message)
//       }
//       .managed(by: self)
//
//   // 2. 手动持有令牌，自行控制生命周期
//   let observation = contentController
//       .addScriptMessageHandler(for: "nativeBridge") { [weak self] message in
//           self?.handleBridgeMessage(message)
//       }
//
// 注意事项：
// - 闭包中必须使用 [weak self]，否则会产生循环引用：
//   VC → WKWebView → Configuration → UserContentController → Proxy → closure → VC
//   循环引用会导致 VC 无法释放，令牌的自动清理机制也随之失效
// - 必须持有返回的 ScriptMessageObservation（通过 managed(by:) 或存为属性），
//   否则令牌立即释放，handler 随之被移除
//

public extension WKUserContentController {
    
    /// 以闭包形式注册 ScriptMessage handler
    ///
    /// - Parameters:
    ///   - name: 消息名称，对应 JS 端 `window.webkit.messageHandlers.<name>.postMessage(...)`
    ///   - handler: 收到消息时的回调；通过 `message.body` 获取 JS 传递的数据
    /// - Returns: 生命周期令牌；令牌释放时自动调用 `removeScriptMessageHandler(forName:)`
    func addScriptMessageHandler(
        for name: String,
        _ handler: @escaping (_ message: WKScriptMessage) -> Void
    ) -> ScriptMessageObservation {
        add(ScriptMessageHandlerProxy(handler), name: name)
        return ScriptMessageObservation(userContentController: self, name: name)
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

// MARK: - ScriptMessageObservation

/// ScriptMessage handler 的生命周期令牌
///
/// 持有此对象期间，对应的 handler 保持注册状态；
/// 对象释放时自动调用 `removeScriptMessageHandler(forName:)` 移除 handler。
///
/// 类似于 `NSKeyValueObservation`：持有 = 观察生效，释放 = 观察结束。
public class ScriptMessageObservation {
    
    /// 注册 handler 的 UserContentController（弱引用，避免循环持有）
    public weak private(set) var userContentController: WKUserContentController?
    
    /// 注册时使用的消息名称
    public let name: String
    
    init(userContentController: WKUserContentController, name: String) {
        self.userContentController = userContentController
        self.name = name
    }
    
    /// 将令牌的生命周期绑定到指定 owner 上
    ///
    /// owner 释放时，令牌随之释放，handler 自动被移除。
    /// 典型用法是传入当前 ViewController。
    ///
    /// - Parameter owner: 持有令牌的对象
    public func managed(by owner: NSObject) {
        owner.scriptMessageObservations.append(self)
    }
    
    deinit {
        userContentController?.removeScriptMessageHandler(forName: name)
    }
    
}

// MARK: - ScriptMessageObservation Storage

private extension NSObject {
    
    static var script_message_observations_key: Void?
    
    /// 通过关联对象存储令牌数组，owner 释放时令牌自动释放
    var scriptMessageObservations: [ScriptMessageObservation] {
        get {
            objc_getAssociatedObject(self, &Self.script_message_observations_key) as? [ScriptMessageObservation] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.script_message_observations_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}