//
//  Created by 姚旭 on 2025/7/1.
//

import UIKit

/// 可配置点击响应区域的 `UIButton` 子类
///
/// - Note: 配置后的区域不可超出父视图范围，否则超出部分仍无法响应事件。
public class HitAreaButton: UIButton {
    
    /// 相对于原始 bounds 的边距调整，负值向外扩展，正值向内收缩
    public var hitInsets: UIEdgeInsets = .zero
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: hitInsets).contains(point)
    }
    
}
