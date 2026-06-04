//
//  Created by 姚旭 on 2025/8/23.
//

import UIKit

/// 仿 UISwitch 样式的自定义开关控件：
/// - 支持自定义圆钮颜色
/// - 支持自定义开/关状态颜色（UISwitch 不支持关状态颜色）
/// - 支持修改控件高度和宽度（UISwitch 不支持修改尺寸）
///
/// 通过 `UIControl.Event.valueChanged` 来处理点击切换事件
public final class ToggleSwitch: UIControl {
    
    // MARK: - 配置属性
    
    /// 控件是否开启
    @IBInspectable public var isOn: Bool = true {
        didSet {
            updateThumbPosition()
            updateAppearance()
        }
    }
    
    /// 两次有效点击之间最小时间间隔（单位秒，0 表示不设置最小时间间隔）
    @IBInspectable public var debounceInterval: TimeInterval = 0
    
    /// 开启时的背景颜色
    @IBInspectable public var onTintColor: UIColor = .systemGreen {
        didSet { updateAppearance() }
    }
    
    /// 关闭时的背景颜色
    @IBInspectable public var offTintColor: UIColor = .init(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16) {
        didSet { updateAppearance() }
    }
    
    /// 圆钮的颜色
    @IBInspectable public var thumbTintColor: UIColor = .white {
        didSet { updateAppearance() }
    }
    
    private let padding: CGFloat = 2
    
    // MARK: - Components
    
    private lazy var trackView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = isOn ? onTintColor : offTintColor
        return v
    }()
    
    private lazy var thumbView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = thumbTintColor
        return v
    }()
    
    // MARK: - Override
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(trackView)
        addSubview(thumbView)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(trackView)
        addSubview(thumbView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 设置 trackView 的 frame 及圆角。
        trackView.frame = bounds
        trackView.layer.cornerRadius = bounds.height / 2
        // 设置 thumbView 的 frame 及圆角。
        let thumbSide = max(bounds.height - 2 * padding, 0)
        let thumbMinX = padding
        let thumbMaxX = bounds.width - thumbSide - padding
        thumbView.frame = .init(
            x: isOn ? thumbMaxX : thumbMinX,
            y: padding,
            width: thumbSide,
            height: thumbSide
        )
        thumbView.layer.cornerRadius = thumbSide / 2
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        guard let touch = touch,
              bounds.contains(touch.location(in: self)) else { return }
        isOn.toggle()
        sendActions(for: .valueChanged)
        if debounceInterval > 0 {
            isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval) { [weak self] in
                self?.isEnabled = true
            }
        }
    }
    
    // MARK: - Private
    
    private func updateAppearance() {
        trackView.backgroundColor = isOn ? onTintColor : offTintColor
        thumbView.backgroundColor = thumbTintColor
    }
    
    private func updateThumbPosition() {
        let minX = padding
        let maxX = bounds.width - thumbView.bounds.width - padding
        thumbView.frame.origin.x = isOn ? maxX : minX
    }
    
}
