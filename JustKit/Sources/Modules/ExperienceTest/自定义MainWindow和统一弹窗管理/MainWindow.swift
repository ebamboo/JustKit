//
//  Created by 姚旭 on 2025/10/7.
//

import UIKit

class BasePopupView: UIView {
    /// 显示优先级
    var priority: Int = 3000
    /// 弹出时间
    fileprivate(set) var popupTime: TimeInterval = Date().timeIntervalSince1970
    /// 加入后显示时，执行可选的自定义动画
    func animate() {}
}

class MainWindow: UIWindow {
    
    // 已加入的 popup views
    // 可在外部查看已加入的弹窗的优先级
    var popupViews: [BasePopupView] {
        subviews.compactMap({ $0 as? BasePopupView })
    }
    
    // 弹出 popup view
    func popup(_ popupView: BasePopupView) {
        // 加入 Window
        popupView.popupTime = Date().timeIntervalSince1970
        addSubview(popupView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            popupView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            popupView.topAnchor.constraint(equalTo: self.topAnchor),
            popupView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        layoutIfNeeded()
        // 根据优先级和弹窗时间排序
        let sortedPopupViews = popupViews.sorted { item0, item1 in
            guard item0.priority != item1.priority else {
                return item0.popupTime < item1.popupTime
            }
            return item0.priority < item1.priority
        }
        sortedPopupViews.forEach { item in
            bringSubviewToFront(item)
        }
        // 执行动画
        popupView.animate()
    }
    
}
