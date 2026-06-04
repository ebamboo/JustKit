//
//  Created by 姚旭 on 2025/7/1.
//

import UIKit

///
/// 渐变色圆角边框/圆环
///
/// 当视图为正方形，且圆角半径为边长一半时，表现为圆环
///
public class GradientBorder: UIView {
    
    // MARK: - 配置属性
    
    /// 渐变边框的圆角半径
    @IBInspectable public var cornerRadius: CGFloat = 12 {
        didSet {
            gradientLayer.cornerRadius = cornerRadius
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
    }
    /// 渐变边框的边框厚度
    @IBInspectable public var borderWidth: CGFloat = 2 {
        didSet {
            maskLayer.lineWidth = borderWidth * 2
        }
    }
    
    /// 渐变色
    public var colors: [UIColor] = [UIColor.red, UIColor.orange, UIColor.systemTeal] {
        didSet {
            gradientLayer.colors = colors.map(\.cgColor)
        }
    }
    /// 渐变起点位置
    @IBInspectable public var startPoint: CGPoint = .init(x: 0, y: 0.5) {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    /// 渐变终点位置
    @IBInspectable public var endPoint: CGPoint = .init(x: 1, y: 0.5) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    // MARK: - Components
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.cornerRadius = cornerRadius
        layer.colors = colors.map(\.cgColor)
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        return layer
    }()
    
    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = borderWidth * 2
        layer.lineJoin = .round
        layer.lineCap = .round
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    // MARK: - Override
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.mask = maskLayer
        layer.addSublayer(gradientLayer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        gradientLayer.mask = maskLayer
        layer.addSublayer(gradientLayer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            gradientLayer.colors = colors.map(\.cgColor)
        }
    }
    
}
