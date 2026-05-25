//
//  Created by 姚旭 on 2021/4/25.
//

import UIKit

///
/// 便捷弹窗（Alert / ActionSheet）
///
/// presentAlert 以居中弹窗形式展示，适用于确认、提示等场景；
/// presentSheet 以底部抽屉形式展示，适用于多选项操作；
///
/// 注意：仅支持 iPhone 模式；
/// 若需适配 iPad，ActionSheet 会以 Popover 形式呈现，
/// 需额外配置 popoverPresentationController 的 sourceView / sourceRect，否则会崩溃；
///
public extension UIViewController {
    
    func presentAlert(
        title: String?,
        message: String?,
        actionsTitle: [String],
        actionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        let vc = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        for (index, actionTitle) in actionsTitle.enumerated() {
            let btn = UIAlertAction(title: actionTitle, style: .default) { action in
                actionsHandler(index, action)
            }
            vc.addAction(btn)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func presentSheet(
        title: String?,
        message: String?,
        cancelTitle: String,
        cancelHandler: @escaping (_ action: UIAlertAction) -> Void,
        optionsTitle: [String],
        optionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelBtn = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler)
        vc.addAction(cancelBtn)
        for (index, optionTitle) in optionsTitle.enumerated() {
            let optionBtn = UIAlertAction(title: optionTitle, style: .default) { action in
                optionsHandler(index, action)
            }
            vc.addAction(optionBtn)
        }
        present(vc, animated: true, completion: nil)
    }
    
}

///
/// 便捷子控制器管理
///
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
