//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

/// 为 UIGestureRecognizer 提供基于闭包的事件处理，替代传统的 target-action 模式
///
/// 支持在初始化时直接传入闭包，也支持后续追加多个 handler；
/// 通过关联对象持有 target 包装对象，确保其生命周期与手势识别器一致。
///
/// - Note: handler 闭包会接收手势识别器作为参数，注意避免在闭包中强引用该手势识别器导致循环引用
public extension UIGestureRecognizer {
    
    /// 使用闭包初始化手势识别器
    convenience init(action handler: @escaping (UIGestureRecognizer) -> Void) {
        let target = ActionHandlerTarget(handler: handler)
        self.init(target: target, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTargets.append(target)
    }
    
    /// 追加一个闭包处理
    func addActionHandler(_ handler: @escaping (UIGestureRecognizer) -> Void) {
        let target = ActionHandlerTarget(handler: handler)
        addTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTargets.append(target)
    }
    
    /// 移除所有通过闭包添加的处理
    func removeAllActionHandlers() {
        actionHandlerTargets.forEach { target in
            removeTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)))
        }
        actionHandlerTargets.removeAll()
    }
    
}

private extension UIGestureRecognizer {
    
    /// 闭包包装对象，桥接闭包与 target-action 机制
    class ActionHandlerTarget {
        var handler: (UIGestureRecognizer) -> Void
        init(handler: @escaping (UIGestureRecognizer) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: UIGestureRecognizer) {
            handler(sender)
        }
    }
    
    static var action_handler_targets_key: Void?
    var actionHandlerTargets: [ActionHandlerTarget] {
        get {
            objc_getAssociatedObject(self, &Self.action_handler_targets_key) as? [ActionHandlerTarget] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.action_handler_targets_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
