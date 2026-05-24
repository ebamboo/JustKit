//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

/// 为 UIBarButtonItem 提供基于闭包的事件处理，替代传统的 target-action 模式
///
/// UIBarButtonItem 只有一个 action，因此使用单个 target 包装对象（非数组）；
/// 调用 `setActionHandler` 会替换已有的 handler。
///
/// - Note: handler 闭包会接收 UIBarButtonItem 作为参数，注意避免在闭包中强引用该 item 导致循环引用
public extension UIBarButtonItem {
    
    /// 使用标题和闭包初始化
    convenience init(title: String?, style: UIBarButtonItem.Style, action handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        self.init(title: title, style: style, target: newTarget, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTarget = newTarget
    }
    
    /// 使用图片和闭包初始化
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        self.init(image: image, style: style, target: newTarget, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTarget = newTarget
    }
    
    /// 替换当前的闭包处理，旧 target 通过关联对象替换自动释放
    func setActionHandler(_ handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        target = newTarget
        action = #selector(ActionHandlerTarget.invoke(_:))
        actionHandlerTarget = newTarget
    }
    
}

private extension UIBarButtonItem {
    
    /// 闭包包装对象，桥接闭包与 target-action 机制
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
