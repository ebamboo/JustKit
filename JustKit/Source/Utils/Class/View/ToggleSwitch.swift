//
//  Created by 姚旭 on 2025/8/23.
//

import UIKit

/// 仿 `UISwitch` 样式的自定义开关控件，弥补系统控件的以下限制：
/// - 支持自定义关闭状态背景色（`UISwitch` 仅支持 `onTintColor`）
/// - 支持任意尺寸（`UISwitch` 固定为 51×31）
/// - 支持自定义圆钮颜色
///
/// 用户点击切换时，控件发送 `.valueChanged` 事件，通过读取 `isOn` 获取当前状态。
///
/// ```swift
/// let toggle = ToggleSwitch()
/// toggle.onTintColor = .systemBlue
/// toggle.offTintColor = .systemGray5
/// toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
///
/// @objc func switchChanged(_ sender: ToggleSwitch) {
///     print("当前状态: \(sender.isOn)")
/// }
/// ```
public final class ToggleSwitch: UIControl {
    
    // MARK: - 配置属性
    
    /// 开关状态，`true` 为开启，`false` 为关闭。修改后立即更新外观。
    @IBInspectable public var isOn: Bool = true {
        didSet {
            updateThumbPosition()
            updateAppearance()
        }
    }
    
    /// 防抖间隔（单位秒）。在此时间内，控件将忽略重复点击。设为 0 表示不启用防抖。
    @IBInspectable public var debounceInterval: TimeInterval = 0
    
    /// 开启状态的轨道背景色
    @IBInspectable public var onTintColor: UIColor = .systemGreen {
        didSet { updateAppearance() }
    }
    
    /// 关闭状态的轨道背景色
    @IBInspectable public var offTintColor: UIColor = .init(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16) {
        didSet { updateAppearance() }
    }
    
    /// 圆钮颜色
    @IBInspectable public var thumbTintColor: UIColor = .white {
        didSet { updateAppearance() }
    }
    
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
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        guard let touch = touch else { return }
        let location = touch.location(in: self)
        guard bounds.contains(location)  else { return }
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
    
    private let padding: CGFloat = 2
    
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
