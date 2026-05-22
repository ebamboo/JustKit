//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit
import WebKit

// MARK: - ================================
// MARK: -

public extension WKUserContentController {
    
    /// 添加响应 ScriptMessage(name) 的 handler
    func addScriptMessageHandler(for name: String, _ handler: @escaping (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void) -> ScriptMessageHandlerAddition {
        add(ScriptMessageHandlerTarget(handler), name: name)
        return ScriptMessageHandlerAddition(userContentController: self, name: name)
    }
    
}

private extension WKUserContentController {
    
    class ScriptMessageHandlerTarget: NSObject, WKScriptMessageHandler {
        var handler: (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void
        init(_ handler: @escaping (_ userContentController: WKUserContentController, _ message: WKScriptMessage) -> Void) { self.handler = handler }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) { handler(userContentController, message) }
    }
    
}

// MARK: - ================================
// MARK: -

public class ScriptMessageHandlerAddition {
    
    weak private(set) var userContentController: WKUserContentController?
    let name: String
    
    init(userContentController: WKUserContentController, name: String) {
        self.userContentController = userContentController
        self.name = name
    }
    
    func managed(by owner: NSObject) {
        owner.scriptMessageHandlerAdditions.append(self)
    }
    
    deinit {
        userContentController?.removeScriptMessageHandler(forName: name)
    }
    
}

private extension NSObject {
    
    static var script_message_handler_additions_key = "script_message_handler_additions_key"
    var scriptMessageHandlerAdditions: [ScriptMessageHandlerAddition] {
        get {
            withUnsafePointer(to: &Self.script_message_handler_additions_key) { key in
                objc_getAssociatedObject(self, key) as? [ScriptMessageHandlerAddition] ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.script_message_handler_additions_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}
