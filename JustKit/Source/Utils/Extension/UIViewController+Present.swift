//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

// MARK: - Alert & ActionSheet

///
/// 便捷弹窗（Alert / ActionSheet）
///
/// - `presentAlert`：居中弹窗，适用于确认、提示等场景
/// - `presentSheet`：底部抽屉，适用于多选项操作
///
/// 注意事项：
/// - 所有按钮统一使用 `.default` 样式，不支持 `.destructive`；如需自定义样式请直接使用 UIAlertController
/// - `presentSheet` 仅适用于 iPhone；iPad 上 ActionSheet 以 Popover 形式呈现，
///   需额外配置 `popoverPresentationController` 的 sourceView / sourceRect，否则会崩溃
///
public extension UIViewController {
    
    /// 以居中 Alert 形式展示弹窗
    ///
    /// - Parameters:
    ///   - title: 弹窗标题，传 nil 则不显示
    ///   - message: 弹窗正文，传 nil 则不显示
    ///   - actionTitles: 按钮标题数组，按传入顺序排列
    ///   - actionsHandler: 按钮点击回调；index 对应 actionTitles 中的下标
    func presentAlert(
        title: String?,
        message: String?,
        actionTitles: [String],
        actionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, actionTitle) in actionTitles.enumerated() {
            let action = UIAlertAction(title: actionTitle, style: .default) { alertAction in
                actionsHandler(index, alertAction)
            }
            vc.addAction(action)
        }
        present(vc, animated: true, completion: nil)
    }
    
    /// 以底部 ActionSheet 形式展示弹窗
    ///
    /// - Parameters:
    ///   - title: 弹窗标题，传 nil 则不显示
    ///   - message: 弹窗正文，传 nil 则不显示
    ///   - cancelTitle: 取消按钮标题（始终显示在最底部，样式为 `.cancel`）
    ///   - cancelHandler: 取消按钮点击回调
    ///   - optionTitles: 选项按钮标题数组，按传入顺序排列
    ///   - optionsHandler: 选项按钮点击回调；index 对应 optionTitles 中的下标
    func presentSheet(
        title: String?,
        message: String?,
        cancelTitle: String,
        cancelHandler: @escaping (_ action: UIAlertAction) -> Void,
        optionTitles: [String],
        optionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler)
        vc.addAction(cancelAction)
        for (index, optionTitle) in optionTitles.enumerated() {
            let optionAction = UIAlertAction(title: optionTitle, style: .default) { alertAction in
                optionsHandler(index, alertAction)
            }
            vc.addAction(optionAction)
        }
        present(vc, animated: true, completion: nil)
    }
    
}

// MARK: - Popover

///
/// 便捷弹出 Popover 页面
///
/// 以 Popover 样式 present 指定的视图控制器，在 iPhone 上强制保持 Popover 形式，不会自适应为全屏。
/// 配合 `ArrowlessPopoverBackgroundView` 可隐藏箭头并自定义间距。
///
/// 注意事项：
/// - 被弹出的 VC 需提前设置 `preferredContentSize`，否则尺寸可能异常
/// - `onDismiss` 仅在用户点击外部区域关闭时触发；VC 内部主动调用 `dismiss` 不会触发，
///   主动关闭的后续逻辑应在 `dismiss(animated:completion:)` 的 completion 中处理
///
/// 示例：
/// ```swift
/// // 1. 系统默认样式（带箭头，系统自动选择弹出方向）
/// presentPopover(menuVC, sourceView: sender)
///
/// // 2. 无箭头（使用默认间距 8pt）
/// presentPopover(menuVC, sourceView: sender, backgroundClass: ArrowlessPopoverBackgroundView.self)
///
/// // 3. 无箭头 + 自定义间距（spacing 为全局静态属性，需在 present 前设置）
/// ArrowlessPopoverBackgroundView.spacing = 12
/// presentPopover(menuVC, sourceView: sender, arrowDirections: .up, backgroundClass: ArrowlessPopoverBackgroundView.self)
///
/// // 4. 监听外部点击关闭
/// presentPopover(menuVC, sourceView: sender, onDismiss: { [weak self] in self?.refreshUI() })
/// ```
///
public extension UIViewController {
    
    /// 以 Popover 形式弹出视图控制器
    ///
    /// - Parameters:
    ///   - viewController: 要弹出的视图控制器，需提前设置 `preferredContentSize`
    ///   - sourceView: 箭头指向的锚点视图
    ///   - sourceRect: 锚点区域；不传时使用 sourceView.bounds（随屏幕旋转自动适配）；传入固定值则不会随旋转更新
    ///   - arrowDirections: 允许的箭头方向，影响弹窗相对于锚点的定位方向
    ///   - backgroundClass: 自定义背景视图类；传 `ArrowlessPopoverBackgroundView.self` 可隐藏箭头
    ///   - onDismiss: 用户点击外部区域关闭弹窗时的回调（主动 dismiss 不触发）
    func presentPopover(
        _ viewController: UIViewController,
        sourceView: UIView,
        sourceRect: CGRect? = nil,
        arrowDirections: UIPopoverArrowDirection = .any,
        backgroundClass: (any UIPopoverBackgroundViewMethods.Type)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let delegate = PopoverDelegate(onDismiss: onDismiss)
        viewController.popoverDelegate = delegate
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sourceView
        if let sourceRect {
            viewController.popoverPresentationController?.sourceRect = sourceRect
        }
        viewController.popoverPresentationController?.permittedArrowDirections = arrowDirections
        viewController.popoverPresentationController?.popoverBackgroundViewClass = backgroundClass
        viewController.popoverPresentationController?.delegate = delegate
        present(viewController, animated: true)
    }
    
}

// MARK: - Popover Public Support

///
/// 无箭头的 Popover 背景视图
///
/// 隐藏系统默认的箭头、阴影和背景样式，弹窗内容的外观完全由内容控制器自行决定。
///
/// 注意事项：
/// - `spacing` 是全局静态属性，修改后影响所有后续弹出的 Popover；需在每次 `presentPopover` 前设置所需值
/// - 仅配合 `presentPopover` 使用，通过 `backgroundClass` 参数传入
///
public class ArrowlessPopoverBackgroundView: UIPopoverBackgroundView {
    
    /// 锚点视图与弹窗之间的间距（默认 8pt）
    ///
    /// 全局静态属性，需在调用 `presentPopover` 前设置；修改后影响所有后续弹出的 Popover
    public static var spacing: CGFloat = 8
    
    public override static func arrowHeight() -> CGFloat { spacing }
    public override static func arrowBase() -> CGFloat { 0 }
    public override static func contentViewInsets() -> UIEdgeInsets { .zero }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    // 以下属性仅为满足 UIPopoverBackgroundView 的重写要求提供存储，系统会在布局时设置实际值
    
    private var _arrowOffset: CGFloat = 0
    public override var arrowOffset: CGFloat {
        get { _arrowOffset }
        set { _arrowOffset = newValue; setNeedsLayout() }
    }
    
    private var _arrowDirection: UIPopoverArrowDirection = .up
    public override var arrowDirection: UIPopoverArrowDirection {
        get { _arrowDirection }
        set { _arrowDirection = newValue; setNeedsLayout() }
    }
    
}

// MARK: - Popover Private Support

private extension UIViewController {
    
    static var popover_delegate_key: Void?
    
    /// 通过关联对象在被弹出的 VC 上持有 delegate，各弹窗独立持有，dismiss 后自动释放
    var popoverDelegate: PopoverDelegate? {
        get {
            objc_getAssociatedObject(self, &Self.popover_delegate_key) as? PopoverDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.popover_delegate_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 强制 iPhone 上保持 Popover 样式 + 处理外部点击关闭回调
    class PopoverDelegate: NSObject, UIPopoverPresentationControllerDelegate {
        
        var onDismiss: (() -> Void)?
        
        init(onDismiss: (() -> Void)?) {
            self.onDismiss = onDismiss
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            .none
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            onDismiss?()
            presentationController.presentedViewController.popoverDelegate = nil
        }
        
    }
    
}
