//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit
import WebKit

// MARK: - ================================
// MARK: -

public extension WKUserContentController {
    
    /// 添加响应 ScriptMessage(name) 的 handler
    @discardableResult func addScriptMessageHandler(
        for name: String,
        _ handler: @escaping (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void
    ) -> ScriptMessageObservation {
        add(ScriptMessageHandlerProxy(handler), name: name)
        return ScriptMessageObservation(userContentController: self, name: name)
    }
    
}

private extension WKUserContentController {
    
    class ScriptMessageHandlerProxy: NSObject, WKScriptMessageHandler {
        let handler: (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void
        init(
            _ handler: @escaping (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void
        ) {
            self.handler = handler
        }
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            handler(userContentController, message)
        }
    }
    
}

// MARK: - ================================
// MARK: -

public class ScriptMessageObservation {
    
    public weak private(set) var userContentController: WKUserContentController?
    public let name: String
    
    public init(userContentController: WKUserContentController, name: String) {
        self.userContentController = userContentController
        self.name = name
    }
    
    public func managed(by owner: NSObject) {
        owner.scriptMessageObservations.append(self)
    }
    
    deinit {
        userContentController?.removeScriptMessageHandler(forName: name)
    }
    
}

private extension NSObject {
    
    static var script_message_observations_key: Void?
    var scriptMessageObservations: [ScriptMessageObservation] {
        get {
            objc_getAssociatedObject(self, &Self.script_message_observations_key) as? [ScriptMessageObservation] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.script_message_observations_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
