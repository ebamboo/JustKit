//
//  Created by 姚旭 on 2025/7/8.
//

import UIKit

/// 渐变色文字的 `UILabel` 子类，支持多行，可在 Interface Builder 中配置渐变方向。
///
/// - Note: `backgroundColor` 和 `textColor` 由内部固定，外部设置无效。
///   需要背景色时，请在外层包裹容器视图。
public class GradientLabel: UILabel {

    /// 渐变色数组，支持动态颜色（如暗黑模式自适应颜色）
    public var colors: [UIColor] = [.red, .orange, .systemTeal] {
        didSet { setNeedsDisplay() }
    }

    /// 渐变起点
    @IBInspectable public var startPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet { setNeedsDisplay() }
    }

    /// 渐变终点
    @IBInspectable public var endPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet { setNeedsDisplay() }
    }
    
    public override var backgroundColor: UIColor? {
        get { .clear }
        set { super.backgroundColor = .clear }
    }
    
    public override var textColor: UIColor! {
        get { .black }
        set { super.textColor = .black }
    }
    
    public override var contentMode: UIView.ContentMode {
        // redraw 保证 bounds 变化时必定触发 `drawText(in:)`
        get { .redraw }
        set { super.contentMode = .redraw }
    }
    
    public override func drawText(in rect: CGRect) {
        // 步骤 1：由 UILabel 自身完成文字渲染。
        // 此时绘图上下文中只有文字像素（alpha > 0），其余区域透明（alpha = 0）。
        super.drawText(in: rect)
        // 步骤 2：获取当前绘图上下文，并根据 colors 创建 CGGradient 对象。
        guard let context = UIGraphicsGetCurrentContext(),
              let gradient = CGGradient(
                  colorsSpace: CGColorSpaceCreateDeviceRGB(),
                  colors: colors.map(\.cgColor) as CFArray,
                  locations: nil
              ) else { return }
        // 步骤 3：保存图形状态，设置 .sourceIn 混合模式后绘制线性渐变。
        // .sourceIn 公式：输出 = 源颜色 × 目标 alpha
        //  - 文字区域（alpha = 1）：输出 = 渐变色 × 1 = 渐变色 → 文字呈现渐变
        //  - 空白区域（alpha = 0）：输出 = 渐变色 × 0 = 透明   → 背景不受影响
        context.saveGState()
        context.setBlendMode(.sourceIn)
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.width * startPoint.x, y: rect.height * startPoint.y),
            end: CGPoint(x: rect.width * endPoint.x, y: rect.height * endPoint.y),
            options: []
        )
        // 步骤 4：恢复图形状态，避免混合模式污染后续绘制操作。
        context.restoreGState()
    }
    
}
