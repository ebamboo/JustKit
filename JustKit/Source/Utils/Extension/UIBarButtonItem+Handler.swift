//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

public extension UIBarButtonItem {
    
    convenience init(title: String?, style: UIBarButtonItem.Style, action handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        self.init(title: title, style: style, target: newTarget, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTarget = newTarget
    }
    
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        self.init(image: image, style: style, target: newTarget, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTarget = newTarget
    }
    
    func setActionHandler(_ handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        target = newTarget
        action = #selector(ActionHandlerTarget.invoke(_:))
        actionHandlerTarget = newTarget
    }
    
}

private extension UIBarButtonItem {
    
    class ActionHandlerTarget {
        var handler: (UIBarButtonItem) -> Void
        init(handler: @escaping (UIBarButtonItem) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: UIBarButtonItem) {
            handler(sender)
        }
    }
    
    static var action_handler_target_key: Void?
    var actionHandlerTarget: ActionHandlerTarget? {
        get {
            objc_getAssociatedObject(self, &Self.action_handler_target_key) as? ActionHandlerTarget
        }
        set {
            objc_setAssociatedObject(self, &Self.action_handler_target_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
