//
//  Created by 姚旭 on 2025/7/1.
//

import UIKit

///
/// 拓展 Button 的响应范围
///
/// 注意：拓展之后的范围不可超出父视图的范围，否则超出的部分仍然无法响应事件。
///
class ExpandedButton: UIButton {

    /// 指定相对于原始 bounds 缩放范围；
    /// 例如：
    ///  UIEdgeInsets.init(top: 3, left: 4, bottom: 5, right: 6) 表示上左下右分别向内偏移3、4、5、6；
    ///  UIEdgeInsets.init(top: -3, left: -4, bottom: -5, right: -6) 表示上左下右分别外偏移3、4、5、6
    var hitInsets: UIEdgeInsets = .zero

}

extension ExpandedButton {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.inset(by: hitInsets)
        return expandedBounds.contains(point)
    }
    
}
