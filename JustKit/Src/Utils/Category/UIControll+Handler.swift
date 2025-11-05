//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

public extension UIControl {
    
    /// 添加响应 events 的 handler
    func addActionHandler(for events: Event, _ handler: @escaping (UIControl) -> Void) {
        let target = ActionHandlerTarget(events: events, handler: handler)
        addTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
        actionHandlerTargets.append(target)
    }
    
    /// 移除响应 events 的所有 handler
    func removeAllActionHandlers(for events: Event = .allEvents) {
        actionHandlerTargets.removeAll { target in
            let newEvents = target.events.subtracting(events) // 返回 target.events 减去 events 的结果
            if newEvents.isEmpty {
                return true
            } else {
                removeTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
                target.events = newEvents
                addTarget(target, action: #selector(ActionHandlerTarget.invoke(_:)), for: target.events)
                return false
            }
        }
    }
    
}

private extension UIControl {
    
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
    
    static var action_handler_targets_key = "action_handler_targets_key"
    var actionHandlerTargets: [ActionHandlerTarget] {
        get {
            withUnsafePointer(to: &Self.action_handler_targets_key) { key in
                objc_getAssociatedObject(self, key) as? [ActionHandlerTarget] ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.action_handler_targets_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}
