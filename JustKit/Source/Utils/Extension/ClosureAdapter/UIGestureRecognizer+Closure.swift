//
//  Created by 姚旭 on 2022/4/13.
//

import UIKit

///
/// 为 `UIGestureRecognizer` 提供基于闭包的事件处理，替代传统的 target-action 模式。
///
/// 支持在初始化时直接传入闭包，也支持后续通过 `addActionHandler(_:)` 追加多个 handler。
///
public extension UIGestureRecognizer {
    
    /// 使用闭包创建手势识别器。
    ///
    /// - Parameter handler: 手势触发时执行的闭包。
    convenience init(action handler: @escaping (UIGestureRecognizer) -> Void) {
        let target = ClosureProxy(handler: handler)
        self.init(target: target, action: #selector(ClosureProxy.invoke(_:)))
        closureProxies.append(target)
    }
    
    /// 追加一个闭包处理。
    ///
    /// - Parameter handler: 手势触发时执行的闭包。
    func addActionHandler(_ handler: @escaping (UIGestureRecognizer) -> Void) {
        let target = ClosureProxy(handler: handler)
        addTarget(target, action: #selector(ClosureProxy.invoke(_:)))
        closureProxies.append(target)
    }
    
    /// 移除所有通过闭包添加的处理。
    func removeAllActionHandlers() {
        closureProxies.forEach { target in
            removeTarget(target, action: #selector(ClosureProxy.invoke(_:)))
        }
        closureProxies.removeAll()
    }
    
}

private extension UIGestureRecognizer {
    
    /// UIGestureRecognizer 的 target 对象，将 action 转发给闭包
    class ClosureProxy {
        let handler: (UIGestureRecognizer) -> Void
        init(handler: @escaping (UIGestureRecognizer) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: UIGestureRecognizer) {
            handler(sender)
        }
    }
    
    static var closure_proxies_key: Void?
    var closureProxies: [ClosureProxy] {
        get {
            objc_getAssociatedObject(self, &Self.closure_proxies_key) as? [ClosureProxy] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.closure_proxies_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
