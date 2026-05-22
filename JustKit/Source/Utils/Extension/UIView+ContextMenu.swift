//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

///
/// 通过设置 customContextMenu 在用户长按或者使用 3D Touch时触发自定义的上下文菜单；
///
/// 注意：无法通过编程的方式触发上下文菜单，例如无法在点击视图时手动唤起上下文菜单；
///
/// 如果想要在点击视图时唤起上下文菜单，可以使用 UIButton 来实现；
///

public extension UIView {
    
    /// 传入自定义的上下文菜单
    var customContextMenu: UIMenu? {
        get {
            withUnsafePointer(to: &Self.context_menu_key) { key in
                objc_getAssociatedObject(self, key) as? UIMenu
            }
        }
        set {
            withUnsafePointer(to: &Self.context_menu_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
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
    
    static var context_menu_key = "context_menu_key"
    
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
