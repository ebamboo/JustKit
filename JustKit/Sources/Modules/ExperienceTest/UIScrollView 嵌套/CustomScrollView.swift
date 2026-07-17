//
//  Created by 姚旭 on 2022/9/26.
//

import UIKit


class MainScrollView: UIScrollView { // 设置 bounces = false 来保证主 scroll view 偏移量不能小于 0
    
    var lastContentOffset: CGPoint = .zero
    @IBInspectable var maxContentOffsetY: CGFloat = .zero // 最大偏移量
    
}

class SubScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    @IBOutlet var mainScrollView: MainScrollView!
    
    var lastContentOffset: CGPoint = .zero
    var decelerateVelocity: CGPoint? = nil // 减速阶段初速度，根据它判断惯性滑动时的方向
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只把拖动手势共享给 mainScrollView
        return otherGestureRecognizer === mainScrollView.panGestureRecognizer
    }
    
}

class SubTableView: UITableView, UIGestureRecognizerDelegate {
    
    @IBOutlet var mainScrollView: MainScrollView!
    
    var lastContentOffset: CGPoint = .zero
    var decelerateVelocity: CGPoint? = nil // 减速阶段初速度，根据它判断惯性滑动时的方向
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只把拖动手势共享给 mainScrollView
        return otherGestureRecognizer === mainScrollView.panGestureRecognizer
    }
    
}
