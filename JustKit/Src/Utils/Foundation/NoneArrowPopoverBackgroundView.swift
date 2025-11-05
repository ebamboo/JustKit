//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

public protocol NoneArrowPopoverBackgroundViewSpacing {
    static var value: CGFloat { get }
}

public struct NoneArrowPopoverBackgroundViewDefaultSpacing: NoneArrowPopoverBackgroundViewSpacing {
    public static let value: CGFloat = 8
}

/// 通过传入   --遵循 NoneArrowPopoverBackgroundViewSpacing 协议的类型--   可以控制锚点视图和弹窗视图之间的间距
public class NoneArrowPopoverBackgroundView<Spacing>: UIPopoverBackgroundView where Spacing: NoneArrowPopoverBackgroundViewSpacing {
    
    public override static func arrowBase() -> CGFloat { 0 }
        
    public override static func arrowHeight() -> CGFloat { Spacing.value }
    
    public override static func contentViewInsets() -> UIEdgeInsets { .zero }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    private var _arrowOffset: CGFloat = 0
    public override var arrowOffset: CGFloat {
        get { _arrowOffset }
        set { _arrowOffset = newValue }
    }
    
    private var _arrowDirection: UIPopoverArrowDirection = .any
    public override var arrowDirection: UIPopoverArrowDirection {
        get { _arrowDirection }
        set { _arrowDirection = newValue }
    }
    
}

