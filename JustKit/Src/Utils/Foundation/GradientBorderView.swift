//
//  Created by 姚旭 on 2025/7/1.
//

import UIKit

///
/// 渐变色圆角边框/圆环
///
/// 当视图为正方形，且圆角半径为边长一半时，表现为圆环
///
@IBDesignable class GradientBorderView: UIView {
    
    // MARK: public
    
    /// 渐变边框的圆角半径
    @IBInspectable var gradientCornerRadius: CGFloat = 12 {
        didSet {
            gradientLayer.cornerRadius = gradientCornerRadius
            maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: gradientCornerRadius).cgPath
        }
    }
    /// 渐变边框的边框厚度
    @IBInspectable var gradientBorderWidth: CGFloat = 2 {
        didSet {
            maskLayer.lineWidth = gradientBorderWidth * 2
        }
    }
    
    /// 渐变色
    var gradientColors: [CGColor] = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.systemTeal.cgColor] {
        didSet {
            gradientLayer.colors = gradientColors
        }
    }
    /// 渐变起点位置
    @IBInspectable var gradientStartPoint: CGPoint = .init(x: 0, y: 0.5) {
        didSet {
            gradientLayer.startPoint = gradientStartPoint
        }
    }
    /// 渐变终点位置
    @IBInspectable var gradientEndPoint: CGPoint = .init(x: 1, y: 0.5) {
        didSet {
            gradientLayer.endPoint = gradientEndPoint
        }
    }
    
    // MARK: ui
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.cornerRadius = gradientCornerRadius
        layer.colors = gradientColors
        layer.startPoint = gradientStartPoint
        layer.endPoint = gradientEndPoint
        return layer
    }()
    
    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = gradientBorderWidth * 2
        layer.lineJoin = .round
        layer.lineCap = .round
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    // MARK: life
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        gradientLayer.mask = maskLayer
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: gradientCornerRadius).cgPath
    }
    
}
