//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

///
/// 为 `UIControl` 提供基于闭包的事件处理，替代传统的 target-action 模式。
///
/// 支持为同一控件添加多个 handler，每个 handler 可监听不同的事件类型。
///
public extension UIControl {
    
    /// 添加响应指定事件的闭包处理。
    ///
    /// - Parameters:
    ///   - events: 要监听的事件类型。
    ///   - handler: 事件触发时执行的闭包。
    func addActionHandler(for events: Event, _ handler: @escaping (UIControl) -> Void) {
        let target = ActionHandlerTarget(events: events, handler: handler)
        addTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
        actionHandlerTargets.append(target)
    }
    
    /// 移除指定事件的所有闭包处理。
    ///
    /// 若某个 handler 同时监听了多种事件，仅移除与 `events` 重叠的部分，保留其余事件。
    ///
    /// - Parameter events: 要移除的事件类型，默认为 `.allEvents`。
    func removeAllActionHandlers(for events: Event = .allEvents) {
        actionHandlerTargets.removeAll { target in
            let remainingEvents = target.events.subtracting(events)
            if remainingEvents.isEmpty {
                removeTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
                return true
            } else {
                removeTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: events)
                target.events = remainingEvents
                return false
            }
        }
    }
    
}

private extension UIControl {
    
    /// UIControl 的 target 对象，将 action 转发给闭包
    class ActionHandlerTarget {
        var events: Event
        let handler: (UIControl) -> Void
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
