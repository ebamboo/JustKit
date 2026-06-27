//
//  Created by 姚旭 on 2021/5/17.
//

import UIKit
import MBProgressHUD

/// HUD 工具（Toast & Loading）
///
/// 基于 `MBProgressHUD` 封装，同时提供 UIKit（`UIView` 扩展）和 SwiftUI（`ViewModifier` ）两套接口。
/// SwiftUI 侧为 UIKit 侧的桥接封装，配置变更仅需修改 UIView 扩展。
///
/// - Note: HUD 展示期间宿主视图不响应用户交互。
extension UIView {
    
    private static let hudForegroundColor = UIColor.white
    private static let hudBackgroundColor = UIColor.black

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
        hud.contentColor = UIView.hudForegroundColor
        hud.bezelView.color = UIView.hudBackgroundColor
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
            hud.contentColor = UIView.hudForegroundColor
            hud.bezelView.color = UIView.hudBackgroundColor
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
