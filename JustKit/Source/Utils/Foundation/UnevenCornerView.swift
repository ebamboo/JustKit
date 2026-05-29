//
//  Created by 姚旭 on 2021/12/10.
//

import UIKit

///
/// 支持为四个角分别设置不同圆角半径的 `UIView` 子类，可在 Interface Builder 中直接配置。
///
/// - Note: 使用 `layer.mask` 裁剪，设置了 `layer.shadow` 的阴影将不可见。
///   如需同时使用阴影，需要额外嵌套一个容器视图来承载阴影。
///
public class UnevenCornerView: UIView {
    
    @IBInspectable public var topLeftRadius: CGFloat = 0.0
    @IBInspectable public var topRightRadius: CGFloat = 0.0
    @IBInspectable public var bottomRightRadius: CGFloat = 0.0
    @IBInspectable public var bottomLeftRadius: CGFloat = 0.0
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    private lazy var maskLayer = CAShapeLayer()
    
    private var maskPath: UIBezierPath {
        let rect = bounds
        let path = UIBezierPath()
        if topLeftRadius > 0.0 {
            path.addArc(withCenter: CGPoint(x: topLeftRadius, y: topLeftRadius), radius: topLeftRadius, startAngle: -Double.pi, endAngle: -Double.pi/2, clockwise: true)
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
        }
        if topRightRadius > 0.0 {
            path.addArc(withCenter: CGPoint(x: rect.width-topRightRadius, y: topRightRadius), radius: topRightRadius, startAngle: -Double.pi/2, endAngle: 0, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
        if bottomRightRadius > 0.0 {
            path.addArc(withCenter: CGPoint(x: rect.width-bottomRightRadius, y: rect.height-bottomRightRadius), radius: bottomRightRadius, startAngle: 0, endAngle: Double.pi/2, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        }
        if bottomLeftRadius > 0.0 {
            path.addArc(withCenter: CGPoint(x: bottomLeftRadius, y: rect.height-bottomLeftRadius), radius: bottomLeftRadius, startAngle: Double.pi/2, endAngle: Double.pi, clockwise: true)
        } else {
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        path.close()
        return path
    }
    
}
