//
//  Created by 姚旭 on 2021/12/8.
//

import UIKit

/// 自定义虚线视图，支持水平和垂直两个方向。
///
/// 虚线的粗细和虚线的方向有关：
/// - 水平方向时，粗细 = 视图高度
/// - 垂直方向时，粗细 = 视图宽度
public class DashLine: UIView {

    // MARK: - 配置属性

    /// 是否为水平方向
    @IBInspectable public var isHorizontal: Bool = true
    /// 虚线颜色
    @IBInspectable public var color: UIColor = .gray
    /// 每段虚线的长度
    @IBInspectable public var segmentLength: CGFloat = 10
    /// 虚线段之间的间距
    @IBInspectable public var segmentSpacing: CGFloat = 4

    // MARK: - Override

    public override var backgroundColor: UIColor? {
        get { .clear }
        set { super.backgroundColor = .clear }
    }
    
    public override var contentMode: UIView.ContentMode {
        // redraw 保证 bounds 变化时必定触发 `drawText(in:)`
        get { .redraw }
        set { super.contentMode = .redraw }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        contentMode = .redraw
    }
    
    public override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        if isHorizontal {
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
            path.lineWidth = rect.height
        } else {
            path.move(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
            path.lineWidth = rect.width
        }
        path.setLineDash([segmentLength, segmentSpacing], count: 2, phase: 0)
        color.setStroke()
        path.stroke()
    }

}
