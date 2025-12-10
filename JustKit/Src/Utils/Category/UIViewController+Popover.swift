//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

public extension UIViewController {
    
    /// popoverBackgroundViewClass 参数为空时，使用系统默认的 popover 样式；
    /// 若为 NoneArrowPopoverBackgroundView 类型时，可以达到隐藏箭头的效果；
    func showPopoverMenu(
        _ popoverViewController: UIViewController,
        sourceView: UIView,
        sourceRect: CGRect? = nil, // 不为 nil 时，屏幕旋转和缩放时不会自动适配和恢复
        permittedArrowDirections: UIPopoverArrowDirection = .any,
        popoverBackgroundViewClass: (any UIPopoverBackgroundViewMethods.Type)? = nil
    ) {
        self.popoverPresentationControllerDelegate = PopoverPresentationControllerDelegate()
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.popoverPresentationController?.sourceView = sourceView
        if let sourceRect {
            popoverViewController.popoverPresentationController?.sourceRect = sourceRect
        }
        popoverViewController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        popoverViewController.popoverPresentationController?.popoverBackgroundViewClass = popoverBackgroundViewClass
        popoverViewController.popoverPresentationController?.delegate = self.popoverPresentationControllerDelegate
        present(popoverViewController, animated: true)
    }
    
}

private extension UIViewController {
    
    static var popover_presentation_controller_delegate_key = "popover_presentation_controller_delegate_key"
    var popoverPresentationControllerDelegate: PopoverPresentationControllerDelegate? {
        get {
            withUnsafePointer(to: &Self.popover_presentation_controller_delegate_key) { key in
                objc_getAssociatedObject(self, key) as? PopoverPresentationControllerDelegate
            }
        }
        set {
            withUnsafePointer(to: &Self.popover_presentation_controller_delegate_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    class PopoverPresentationControllerDelegate: NSObject, UIPopoverPresentationControllerDelegate {
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            .none
        }
    }

}
