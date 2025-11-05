//
//  Created by 姚旭 on 2025/10/5.
//

import UIKit

extension UIView {
    
    /// 在 UIStack 中时，自定义的距离下一个元素的间距
    @IBInspectable var afterSpacing: CGFloat {
        get {
            guard let stack = superview as? UIStackView else { return 0 }
            return stack.customSpacing(after: self)
        }
        set {
            guard let stack = superview as? UIStackView else { return }
            stack.setCustomSpacing(newValue, after: self)
        }
    }
    
}
