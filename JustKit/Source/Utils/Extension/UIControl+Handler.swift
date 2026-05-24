//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

/// 为 UIControl 提供基于闭包的事件处理，替代传统的 target-action 模式
///
/// 支持为同一控件添加多个 handler，每个 handler 可监听不同的事件类型；
/// 通过关联对象持有 target 包装对象，确保其生命周期与控件一致。
///
/// - Note: handler 闭包会接收触发事件的控件作为参数，注意避免在闭包中强引用控件导致循环引用
public extension UIControl {
    
    /// 添加响应指定事件的闭包处理
    func addActionHandler(for events: Event, _ handler: @escaping (UIControl) -> Void) {
        let target = ActionHandlerTarget(events: events, handler: handler)
        addTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
        actionHandlerTargets.append(target)
    }
    
    /// 移除指定事件的所有闭包处理，默认移除全部事件
    ///
    /// 若某个 handler 同时监听了多种事件，仅移除与 `events` 重叠的部分，保留其余事件
    func removeAllActionHandlers(for events: Event = .allEvents) {
        actionHandlerTargets.removeAll { target in
            let remainingEvents = target.events.subtracting(events)
            if remainingEvents.isEmpty {
                // target 的全部事件都被移除，取消注册并从数组中删除
                removeTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
                return true
            } else {
                // target 仍有剩余事件，仅取消被移除的部分
                removeTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: events)
                target.events = remainingEvents
                return false
            }
        }
    }
    
}

private extension UIControl {
    
    /// 闭包包装对象，桥接闭包与 target-action 机制
    class ActionHandlerTarget {
        var events: Event
        var handler: (UIControl) -> Void
        init(events: Event, handler: @escaping (UIControl) -> Void) {
            self.events = events
            self.handler = handler
        }
        @objc func invoke(_ sender: UIControl) {
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
