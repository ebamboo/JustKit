//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

// MARK: - Alert & ActionSheet & Popover

public extension UIViewController {
    
    /// 以居中 Alert 形式展示弹窗
    ///
    /// - Parameters:
    ///   - title: 弹窗标题，传 `nil` 则不显示
    ///   - message: 弹窗正文，传 `nil` 则不显示
    ///   - actionTitles: 按钮标题数组，按传入顺序排列
    ///   - actionsHandler: 按钮点击回调；`index` 对应 `actionTitles` 中的下标
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
    /// - Important: 仅适用于 iPhone。iPad 上 ActionSheet 以 Popover 形式呈现，
    ///   需额外配置 `popoverPresentationController`，否则会崩溃。
    ///
    /// - Parameters:
    ///   - title: 弹窗标题，传 `nil` 则不显示
    ///   - message: 弹窗正文，传 `nil` 则不显示
    ///   - cancelTitle: 取消按钮标题，始终显示在最底部，样式为 `.cancel`
    ///   - cancelHandler: 取消按钮点击回调
    ///   - optionTitles: 选项按钮标题数组，按传入顺序排列
    ///   - optionsHandler: 选项按钮点击回调；`index` 对应 `optionTitles` 中的下标
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
    
    /// Popover 箭头样式
    enum PopoverArrowStyle {
        /// 系统默认样式，显示箭头
        case system
        /// 隐藏箭头，`spacing` 为锚点视图与弹窗之间的间距（默认 8pt）
        ///
        /// - Important: 间距为全局共享的静态值，每次调用会覆盖上一次的设置。
        ///   同时存在多个无箭头 Popover 时，所有实例共享最后一次设置的间距。
        case hidden(spacing: CGFloat = 8)
    }
    
    /// 以 Popover 形式弹出视图控制器
    ///
    /// - Important: 被弹出的 VC 需提前设置 `preferredContentSize`，否则尺寸可能异常。
    ///
    /// - Note: `onDismiss` 仅在用户点击外部区域关闭时触发；VC 内部主动调用 `dismiss` 不会触发，
    ///   主动关闭的后续逻辑应在 `dismiss(animated:completion:)` 的 completion 中处理。
    ///
    /// - Parameters:
    ///   - viewController: 要弹出的视图控制器
    ///   - sourceView: 锚点视图，弹窗相对此视图定位
    ///   - sourceRect: 锚点区域；不传时默认使用 `sourceView.bounds`（随旋转自动适配）
    ///   - arrowDirections: 允许的箭头方向，影响弹窗相对于锚点的弹出方位
    ///   - arrowStyle: 箭头样式
    ///   - onDismiss: 用户点击外部区域关闭弹窗时的回调
    func presentPopover(
        _ viewController: UIViewController,
        sourceView: UIView,
        sourceRect: CGRect? = nil,
        arrowDirections: UIPopoverArrowDirection = .any,
        arrowStyle: PopoverArrowStyle = .system,
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
        switch arrowStyle {
        case .system:
            break
        case .hidden(let spacing):
            ArrowlessBackgroundView.spacing = spacing
            viewController.popoverPresentationController?.popoverBackgroundViewClass = ArrowlessBackgroundView.self
        }
        viewController.popoverPresentationController?.delegate = delegate
        present(viewController, animated: true)
    }
    
}

// MARK: - Popover Support

private extension UIViewController {
    
    static var popover_delegate_key: Void?
    var popoverDelegate: PopoverDelegate? {
        get {
            objc_getAssociatedObject(self, &Self.popover_delegate_key) as? PopoverDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.popover_delegate_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
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
    
    /// 无箭头 Popover 背景视图，隐藏系统箭头与阴影
    class ArrowlessBackgroundView: UIPopoverBackgroundView {
        
        // 用以控制锚点视图与弹窗之间的间距
        static var spacing: CGFloat = 8
        
        override static func arrowHeight() -> CGFloat { spacing }
        override static func arrowBase() -> CGFloat { 0 }
        override static func contentViewInsets() -> UIEdgeInsets { .zero }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.shadowColor = UIColor.clear.cgColor
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            layer.shadowColor = UIColor.clear.cgColor
        }
        
        // MARK: UIPopoverBackgroundView Required Overrides
        
        private var _arrowOffset: CGFloat = 0
        override var arrowOffset: CGFloat {
            get { _arrowOffset }
            set { _arrowOffset = newValue; setNeedsLayout() }
        }
        
        private var _arrowDirection: UIPopoverArrowDirection = .up
        override var arrowDirection: UIPopoverArrowDirection {
            get { _arrowDirection }
            set { _arrowDirection = newValue; setNeedsLayout() }
        }
        
    }
    
}
