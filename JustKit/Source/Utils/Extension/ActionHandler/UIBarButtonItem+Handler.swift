//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

///
/// 为 `UIBarButtonItem` 提供基于闭包的事件处理，替代传统的 target-action 模式。
///
/// `UIBarButtonItem` 仅支持单个 action，因此同一时刻只保留一个 handler；
///
public extension UIBarButtonItem {
    
    /// 使用标题和闭包创建 bar button item。
    ///
    /// - Parameters:
    ///   - title: 按钮标题。
    ///   - style: 按钮样式。
    ///   - handler: 点击时执行的闭包。
    convenience init(title: String?, style: UIBarButtonItem.Style, action handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        self.init(title: title, style: style, target: newTarget, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTarget = newTarget
    }
    
    /// 使用图片和闭包创建 bar button item。
    ///
    /// - Parameters:
    ///   - image: 按钮图片。
    ///   - style: 按钮样式。
    ///   - handler: 点击时执行的闭包。
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        self.init(image: image, style: style, target: newTarget, action: #selector(ActionHandlerTarget.invoke(_:)))
        actionHandlerTarget = newTarget
    }
    
    /// 替换当前的闭包处理。
    ///
    /// - Parameter handler: 新的点击处理闭包，替换已有 handler。
    func setActionHandler(_ handler: @escaping (UIBarButtonItem) -> Void) {
        let newTarget = ActionHandlerTarget(handler: handler)
        target = newTarget
        action = #selector(ActionHandlerTarget.invoke(_:))
        actionHandlerTarget = newTarget
    }
    
}

private extension UIBarButtonItem {
    
    /// UIBarButtonItem 的 target 对象，将 action 转发给闭包
    class ActionHandlerTarget {
        let handler: (UIBarButtonItem) -> Void
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
