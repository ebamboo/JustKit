//
//  Created by 姚旭 on 2025/8/23.
//

import UIKit

///
///  一个仿 UISwitch 样式自定义的开关控件：
/// - 支持自定义圆钮颜色
/// - 支持自定义开/关状态颜色（UISwitch不支持关状态颜色）
/// - 支持修改控件高度和宽度（UISwitch不支持修改尺寸）
///
///  通过 UIControl.Event.valueChanged 来处理点击切换事件
///
public class CommonSwitch: UIControl {
    
    // MARK: public
    
    /// 控件是否开启
    @IBInspectable public var isOn: Bool = false {
        didSet {
            updateThumbPosition()
            updateColors()
        }
    }
    
    /// 两次有效点击之间最小时间间隔（单位毫秒，0表示不设置最小时间间隔）
    @IBInspectable public var minTimeInterval: Int = 0
    
    /// 开启时的背景颜色
    @IBInspectable public var onTintColor: UIColor = .systemGreen {
        didSet {
            updateColors()
        }
    }
    
    /// 关闭时的背景颜色
    @IBInspectable public var offTintColor: UIColor = .init(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16) {
        didSet {
            updateColors()
        }
    }
    
    /// 圆钮的颜色
    @IBInspectable public var thumbTintColor: UIColor = .white {
        didSet {
            updateColors()
        }
    }
    
    // MARK: ui
    
    private let backgroundView = UIView()
    private let thumbView = UIView()
    
    // MARK: life
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // 设置初始状态
        addSubview(backgroundView)
        addSubview(thumbView)
        updateColors()
        updateThumbPosition()
        // 添加手势识别
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAction))
        addGestureRecognizer(tapGesture)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 更新背景视图frame
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
        // 更新圆钮视图frame
        let thumbSize = CGSize(width: bounds.height - 4, height: bounds.height - 4)
        thumbView.frame = CGRect(origin: .zero, size: thumbSize)
        thumbView.layer.cornerRadius = thumbSize.height / 2
        // 更新圆钮位置
        updateThumbPosition()
    }
    
    private func updateColors() {
        backgroundView.backgroundColor = isOn ? onTintColor : offTintColor
        thumbView.backgroundColor = thumbTintColor
    }
    
    private func updateThumbPosition() {
        let padding: CGFloat = 2
        let maxX = bounds.width - thumbView.bounds.width - padding
        let minX = padding
        let targetX = isOn ? maxX : minX
        thumbView.frame.origin.x = targetX
        thumbView.frame.origin.y = padding
    }
    
    // MARK: action
    
    @objc private func didTapAction() {
        isOn.toggle()
        sendActions(for: .valueChanged)
        if minTimeInterval > 0 {
            isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(minTimeInterval)) { [weak self] in
                self?.isUserInteractionEnabled = true
            }
        }
    }
    
}
