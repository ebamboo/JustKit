//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

// MARK: - Popover

///
/// 便捷弹出 Popover 页面
///
/// 以 Popover 样式 present 指定的视图控制器；
/// 在 iPhone 上强制使用 .popover 样式，不会自适应为全屏；
/// 配合 ArrowlessPopoverBackgroundView 可隐藏箭头并自定义间距；
///
/// 示例：
/// ```
/// // 1. 系统默认样式（带箭头，系统自动选择弹出方向）
/// let vc = MenuViewController()
/// presentPopover(vc, sourceView: sender)
///
/// // 2. 无箭头（使用默认间距 8pt）
/// let vc = MenuViewController()
/// presentPopover(
///     vc,
///     sourceView: sender,
///     backgroundClass: ArrowlessPopoverBackgroundView.self
/// )
///
/// // 3. 无箭头 + 自定义间距
/// ArrowlessPopoverBackgroundView.spacing = 12
/// let vc = MenuViewController()
/// presentPopover(
///     vc,
///     sourceView: sender,
///     arrowDirections: .up,
///     backgroundClass: ArrowlessPopoverBackgroundView.self
/// )
///
/// // 4. 监听用户点击外部区域关闭（主动 dismiss 不会触发）
/// let vc = MenuViewController()
/// presentPopover(
///     vc,
///     sourceView: sender,
///     onDismiss: { [weak self] in self?.refreshUI() }
/// )
/// ```
///
public extension UIViewController {
    
    /// - Parameters:
    ///   - viewController: 要以 Popover 形式弹出的视图控制器（需提前设置 preferredContentSize）
    ///   - sourceView: Popover 箭头指向的锚点视图
    ///   - sourceRect: 锚点区域；不传时使用 sourceView.bounds，屏幕旋转自动适配；传入固定值则不会随旋转更新
    ///   - arrowDirections: 允许的箭头方向，影响弹窗相对于锚点的定位方向
    ///   - backgroundClass: 自定义背景视图类；传 ArrowlessPopoverBackgroundView.self 可隐藏箭头
    ///   - onDismiss: 用户点击弹窗外部区域导致关闭时的回调；
    ///     注意：在弹出的 VC 内部主动调用 dismiss(animated:completion:) 不会触发此回调，
    ///     主动关闭的后续逻辑应在 dismiss 的 completion 中处理
    func presentPopover(
        _ viewController: UIViewController,
        sourceView: UIView,
        sourceRect: CGRect? = nil,
        arrowDirections: UIPopoverArrowDirection = .any,
        backgroundClass: (any UIPopoverBackgroundViewMethods.Type)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        // delegate 存储在被弹出的 VC 上，各弹窗独立持有，dismiss 后自动释放
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

///
/// 无箭头的 Popover 背景视图
///
/// 隐藏了系统默认的箭头、阴影和背景样式，弹窗内容的外观完全由内容控制器自行决定；
/// 通过设置 ArrowlessPopoverBackgroundView.spacing 来控制锚点视图和弹窗之间的间距（默认 8pt）；
///
public class ArrowlessPopoverBackgroundView: UIPopoverBackgroundView {
    
    /// 锚点视图与弹窗之间的间距，在调用 presentPopover 之前设置；默认 8pt
    public static var spacing: CGFloat = 8
    
    /// 利用 arrowHeight 作为锚点视图与弹窗之间的间距（系统会在箭头方向预留此空间）
    public override static func arrowHeight() -> CGFloat { spacing }
    
    /// 箭头底边宽度，返回 0 表示不绘制箭头
    public override static func arrowBase() -> CGFloat { 0 }
    
    /// 内容视图相对于背景视图的内边距，返回 .zero 表示内容紧贴背景边缘
    public override static func contentViewInsets() -> UIEdgeInsets { .zero }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 移除系统默认的阴影效果
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // 移除系统默认的阴影效果
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    /// 箭头沿边缘方向的偏移量，初始值无意义，系统会在布局时设置实际值；
    /// 此处仅为满足 UIPopoverBackgroundView 的重写要求提供存储；
    private var _arrowOffset: CGFloat = 0
    public override var arrowOffset: CGFloat {
        get { _arrowOffset }
        set { _arrowOffset = newValue; setNeedsLayout() }
    }
    
    /// 箭头方向，初始值无意义，系统会根据可用空间和 permittedArrowDirections 设置实际值；
    /// 此处仅为满足 UIPopoverBackgroundView 的重写要求提供存储；
    private var _arrowDirection: UIPopoverArrowDirection = .up
    public override var arrowDirection: UIPopoverArrowDirection {
        get { _arrowDirection }
        set { _arrowDirection = newValue; setNeedsLayout() }
    }
    
}

// MARK: - Private Support

private extension UIViewController {
    
    /// 关联对象 key，用于在被弹出的 VC 上持有 PopoverDelegate 防止释放
    static var popover_delegate_key: Void?
    var popoverDelegate: PopoverDelegate? {
        get {
            objc_getAssociatedObject(self, &Self.popover_delegate_key) as? PopoverDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.popover_delegate_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 内部 delegate：强制 .none 自适应样式（iPhone 上保持 popover）+ 处理外部点击关闭回调
    class PopoverDelegate: NSObject, UIPopoverPresentationControllerDelegate {
        
        var onDismiss: (() -> Void)?
        
        init(onDismiss: (() -> Void)?) {
            self.onDismiss = onDismiss
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            .none
        }
        
        /// 仅在用户点击外部区域关闭时触发；主动调用 dismiss 不会进入此方法
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            onDismiss?()
            presentationController.presentedViewController.popoverDelegate = nil
        }
        
    }
    
}
