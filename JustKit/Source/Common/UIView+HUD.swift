//
//  Created by 姚旭 on 2021/5/17.
//

import UIKit
import MBProgressHUD

extension UIView {
    
    private static let hudForegroundColor = UIColor.white
    private static let hudBackgroundColor = UIColor.black
    
    func showToast(message: String, detail: String? = nil, duration: TimeInterval = 1.5, completion: (() -> Void)? = nil) {
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
    
    func startLoading(message: String? = nil, detail: String? = nil) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        hud.contentColor = UIView.hudForegroundColor
        hud.bezelView.color = UIView.hudBackgroundColor
        hud.bezelView.style = .solidColor
        
        hud.label.text = message
        hud.detailsLabel.text = detail
    }
    
    func stopLoading() {
        let hud = MBProgressHUD.forView(self)
        hud?.hide(animated: true)
    }
    
}
