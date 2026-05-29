//
//  Created by 姚旭 on 2025/10/16.
//

import UIKit

/// 以 `CAGradientLayer` 作为 layer 的视图。
/// 可以直接通过 `layer` 属性设置渐变颜色、方向等，无需类型转换。
///
/// 使用示例：
/// ```
/// let v = GradientView()
/// v.layer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
/// v.layer.startPoint = CGPoint(x: 0, y: 0.5)
/// v.layer.endPoint = CGPoint(x: 1, y: 0.5)
/// ```
///
/// - Note: 渐变层覆盖在背景（backgroundColor）之上。
public class GradientView: UIView {
    
    public override var layer: CAGradientLayer {
        super.layer as! CAGradientLayer
    }
    
    public override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
}
