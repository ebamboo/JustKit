//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

public extension UIView {
    
    /// 为任意视图提供声明式的上下文菜单配置能力。
    ///
    /// 设置该属性后，用户长按或使用 3D Touch 时将展示对应的上下文菜单。
    /// 设置为 `nil` 可移除已添加的菜单交互。
    ///
    /// - Note: 上下文菜单仅支持系统手势触发，无法通过编程方式主动唤起。
    ///   若需要点击触发菜单，请改用 `UIButton.menu` 配合 `showsMenuAsPrimaryAction`。
    var customContextMenu: UIMenu? {
        get {
            objc_getAssociatedObject(self, &Self.context_menu_key) as? UIMenu
        }
        set {
            objc_setAssociatedObject(self, &Self.context_menu_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            interactions.removeAll { interaction in
                interaction is ContextMenuInteraction
            }
            guard let newValue else { return }
            let interaction = ContextMenuInteraction(menu: newValue)
            addInteraction(interaction)
        }
    }

}

private extension UIView {
    
    static var context_menu_key: Void?
    
    class ContextMenuInteraction: UIContextMenuInteraction {
        let realDelegate: ContextMenuInteractionDelegate
        init(menu: UIMenu) {
            self.realDelegate = ContextMenuInteractionDelegate.init(menu: menu)
            super.init(delegate: self.realDelegate)
        }
    }
    
    class ContextMenuInteractionDelegate: NSObject, UIContextMenuInteractionDelegate {
        let menu: UIMenu
        init(menu: UIMenu) { self.menu = menu }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in self.menu }
        }
    }
    
}
