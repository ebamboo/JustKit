//
//  Created by 姚旭 on 2021/5/17.
//

import UIKit
import MBProgressHUD

/// HUD 工具（Toast & Loading）
///
/// 基于 `MBProgressHUD` 封装，同时提供 UIKit（`UIView` 扩展）和 SwiftUI（`ViewModifier` ）两套接口。
///
/// ## 交互行为
/// HUD 显示期间会阻断宿主视图的用户交互。
///
/// ## Toast
/// - 同一容器同时仅展示一个 Toast。
/// - 新 Toast 会替换当前 Toast
/// - Toast 消失时始终触发 completion，包括自然结束、主动隐藏、被替换三种情况。
///
/// ## Loading
/// - 同一容器同时仅展示一个 Loading HUD。
/// - 更新绑定值时优先复用现有 HUD，仅更新显示内容。
///
extension UIView {
    
    enum HUD {
        fileprivate static let foregroundColor = UIColor.white
        fileprivate static let backgroundColor = UIColor.black
    }

    func showToast(
        message: String,
        detail: String? = nil,
        duration: TimeInterval = 1.5,
        completion: (() -> Void)? = nil
    ) {
        MBProgressHUD.forView(self)?.hide(animated: false)
        
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.contentColor = HUD.foregroundColor
        hud.bezelView.color = HUD.backgroundColor
        hud.bezelView.style = .solidColor
        
        hud.label.text = message
        hud.detailsLabel.text = detail
        hud.completionBlock = completion
        hud.hide(animated: true, afterDelay: duration)
    }
    
    func hideToast() {
        let hud = MBProgressHUD.forView(self)
        hud?.hide(animated: true)
    }
    
    func showLoading(
        message: String? = nil,
        detail: String? = nil
    ) {
        if let hud = MBProgressHUD.forView(self) {
            hud.label.text = message
            hud.detailsLabel.text = detail
        } else {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = .indeterminate
            hud.removeFromSuperViewOnHide = true
            hud.contentColor = HUD.foregroundColor
            hud.bezelView.color = HUD.backgroundColor
            hud.bezelView.style = .solidColor
            
            hud.label.text = message
            hud.detailsLabel.text = detail
        }
    }
    
    func hideLoading() {
        let hud = MBProgressHUD.forView(self)
        hud?.hide(animated: true)
    }
    
}
