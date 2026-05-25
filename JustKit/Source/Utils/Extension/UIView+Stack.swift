//
//  Created by 姚旭 on 2025/10/5.
//

import UIKit

extension UIView {
    
    /// 在 UIStackView 中时，自定义当前视图与下一个排列元素之间的间距
    /// 仅当父视图为 UIStackView 时生效；支持 Interface Builder 设置
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
