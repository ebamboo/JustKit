//
//  Created by 姚旭 on 2025/7/17.
//

import UIKit

@available(iOS 16.0, *)
public extension UIView {

    /// 为任意视图提供声明式的编辑菜单配置能力。
    ///
    /// 设置该属性后，用户长按视图时将弹出对应的编辑菜单。
    /// 设置为 `nil` 可移除已添加的编辑菜单交互和长按手势。
    var editMenu: UIMenu? {
        get {
            objc_getAssociatedObject(self, &Self.edit_menu_key) as? UIMenu
        }
        set {
            objc_setAssociatedObject(self, &Self.edit_menu_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            interactions.removeAll { interaction in
                interaction is EditMenuInteraction
            }
            gestureRecognizers?.removeAll { gesture in
                gesture is EditMenuLongPressGesture
            }
            guard let newValue else { return }
            let interaction = EditMenuInteraction(menu: newValue)
            addInteraction(interaction)
            let longPress = EditMenuLongPressGesture()
            longPress.addTarget(longPress, action: #selector(EditMenuLongPressGesture.handleLongPress(_:)))
            addGestureRecognizer(longPress)
        }
    }

}

@available(iOS 16.0, *)
private extension UIView {

    static var edit_menu_key: Void?

    class EditMenuInteraction: UIEditMenuInteraction {
        let realDelegate: EditMenuInteractionDelegate
        init(menu: UIMenu) {
            self.realDelegate = EditMenuInteractionDelegate(menu: menu)
            super.init(delegate: self.realDelegate)
        }
    }

    class EditMenuInteractionDelegate: NSObject, UIEditMenuInteractionDelegate {
        let menu: UIMenu
        init(menu: UIMenu) { self.menu = menu }
        func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
            menu
        }
    }

    class EditMenuLongPressGesture: UILongPressGestureRecognizer {
        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard recognizer.state == .began else { return }
            guard let view = recognizer.view else { return }
            let location = recognizer.location(in: view)
            let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
            for interaction in view.interactions {
                if let editInteraction = interaction as? UIEditMenuInteraction {
                    editInteraction.presentEditMenu(with: configuration)
                    break
                }
            }
        }
    }

}
