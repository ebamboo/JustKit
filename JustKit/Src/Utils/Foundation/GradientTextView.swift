//
//  Created by 姚旭 on 2025/7/8.
//

import UIKit

///
/// 单行渐变色文字视图
///
class GradientTextView: UILabel {

    // MARK: public
    
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
        layer.colors = gradientColors
        layer.startPoint = gradientStartPoint
        layer.endPoint = gradientEndPoint
        return layer
    }()
    
    private lazy var textLayer: CATextLayer = {
        let layer = CATextLayer()
        layer.foregroundColor = UIColor.black.cgColor
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
        textColor = .clear
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = textLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        textLayer.frame = bounds
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = alignmentForLayer(with: textAlignment)
        textLayer.string = text
    }
    
    // MARK: private
    
    func alignmentForLayer(with alignment: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch alignment {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        @unknown default:
            return .center
        }
    }

}
