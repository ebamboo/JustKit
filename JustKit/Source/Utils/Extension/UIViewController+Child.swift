//
//  Created by 姚旭 on 2021/4/25.
//

import UIKit

public extension UIViewController {
    
    func addChild(
        _ child: UIViewController,
        // container 必须是当前控制器的 self.view 或其子视图，不可传入无关的视图
        in container: UIView,
        // 默认将子控制器的 view 铺满容器，也可通过 layout 闭包自定义布局
        layout: ((_ childView: UIView, _ container: UIView) -> Void)? = nil
    ) {
        addChild(child)
        container.addSubview(child.view)
        if let layout = layout {
            layout(child.view, container)
        } else {
            child.view.translatesAutoresizingMaskIntoConstraints = false
            child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            child.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
        child.didMove(toParent: self)
    }
    
    func removeChild(_ child: UIViewController) {
        // 调用顺序：
        // willMove(toParent: nil) → removeFromSuperview() → removeFromParent()
        // 必须先调用 willMove 通知子控制器即将脱离，再移除视图和父子关系；
        // 若顺序颠倒，子控制器的 viewWillDisappear 等生命周期回调可能不会被正确触发；
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    func removeSelf() {
        // 调用顺序：
        // willMove(toParent: nil) → removeFromSuperview() → removeFromParent()
        // 必须先调用 willMove 通知子控制器即将脱离，再移除视图和父子关系；
        // 若顺序颠倒，子控制器的 viewWillDisappear 等生命周期回调可能不会被正确触发；
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
}
