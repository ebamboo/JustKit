//
//  Created by 姚旭 on 2025/8/23.
//

import UIKit

/// 仿 `UISwitch` 样式的自定义开关控件。
///
/// 支持以下功能：
/// - 自定义圆钮颜色
/// - 自定义开启状态背景色
/// - 自定义关闭状态背景色（`UISwitch` 不支持）
/// - 自定义控件尺寸（`UISwitch` 不支持）
/// - 点击防抖，避免快速连续点击导致状态异常（`UISwitch` 不支持）
///
/// 用户点击切换时，控件发送 `.valueChanged` 事件，通过读取 `isOn` 获取当前状态。
///
/// ```swift
/// let toggle = ToggleSwitch()
/// toggle.onTintColor = .systemBlue
/// toggle.offTintColor = .systemGray5
/// toggle.debounceInterval = 0.5
/// toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
///
/// @objc func switchChanged(_ sender: ToggleSwitch) {
///     print("当前状态: \(sender.isOn)")
/// }
/// ```
public final class ToggleSwitch: UIControl {
    
    // MARK: - Constants
    
    private static let padding: CGFloat = 2
    
    // MARK: - Configuration
    
    /// 开关状态，`true` 为开启，`false` 为关闭。修改后立即更新外观。
    @IBInspectable public var isOn: Bool = false {
        didSet {
            updateThumbPosition()
            updateAppearance()
        }
    }
    
    /// 防抖间隔（单位秒）。在此时间内，控件将忽略重复点击。设为 0 表示不启用防抖。
    @IBInspectable public var debounceInterval: TimeInterval = 0
    
    /// 开启状态的轨道背景色。
    @IBInspectable public var onTintColor: UIColor = .systemGreen {
        didSet { updateAppearance() }
    }
    
    /// 关闭状态的轨道背景色。
    @IBInspectable public var offTintColor: UIColor = .init(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16) {
        didSet { updateAppearance() }
    }
    
    /// 圆钮颜色。
    @IBInspectable public var thumbTintColor: UIColor = .white {
        didSet { updateAppearance() }
    }
    
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
    
    // MARK: - Initializers
    
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
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 设置 trackView 的 frame 及圆角。
        trackView.frame = bounds
        trackView.layer.cornerRadius = bounds.height / 2
        // 设置 thumbView 的 frame 及圆角。
        let thumbSide = max(bounds.height - 2 * Self.padding, 0)
        let thumbMinX = Self.padding
        let thumbMaxX = bounds.width - thumbSide - Self.padding
        thumbView.frame = .init(
            x: isOn ? thumbMaxX : thumbMinX,
            y: Self.padding,
            width: thumbSide,
            height: thumbSide
        )
        thumbView.layer.cornerRadius = thumbSide / 2
    }
    
    // MARK: - Event Handling
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        // 校验触摸位置是否在控件范围内。
        guard let touch = touch else { return }
        let location = touch.location(in: self)
        guard bounds.contains(location) else { return }
        // 切换状态并发送事件。
        isOn.toggle()
        sendActions(for: .valueChanged)
        // 防抖：在指定间隔内禁用交互。
        if debounceInterval > 0 {
            isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval) { [weak self] in
                self?.isEnabled = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func updateAppearance() {
        trackView.backgroundColor = isOn ? onTintColor : offTintColor
        thumbView.backgroundColor = thumbTintColor
    }
    
    private func updateThumbPosition() {
        guard bounds.width > 0 else { return }
        let minX = Self.padding
        let maxX = bounds.width - thumbView.bounds.width - Self.padding
        thumbView.frame.origin.x = isOn ? maxX : minX
    }
    
}
