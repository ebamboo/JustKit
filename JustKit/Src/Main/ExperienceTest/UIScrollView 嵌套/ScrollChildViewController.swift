//
//  Created by 姚旭 on 2022/9/26.
//

import UIKit

class ScrollChildViewController: UIViewController {

    var mainScrollView: MainScrollView!
    @IBOutlet weak var scrollView: SubScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.mainScrollView = mainScrollView
    }

}

// MARK: - 核心

extension ScrollChildViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollView.decelerateVelocity = velocity
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollView.lastContentOffset = scrollView.contentOffset
            self.scrollView.decelerateVelocity = nil
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollView.lastContentOffset = scrollView.contentOffset
        self.scrollView.decelerateVelocity = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let mainScrollView = self.mainScrollView else { return }
        
        // MARK: - 拖拽滚动
        let dragVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        if dragVelocity.y > 0 { // 向下滑动，sub 优先
            if scrollView.contentOffset.y > 0 {
                mainScrollView.contentOffset = mainScrollView.lastContentOffset
                self.scrollView.lastContentOffset = scrollView.contentOffset
            } else if scrollView.contentOffset.y == 0 {
                self.scrollView.lastContentOffset = scrollView.contentOffset
            } else {
                if mainScrollView.contentOffset.y > 0 {
                    self.scrollView.contentOffset.y = 0
                }
            }
            return
        }
        if dragVelocity.y < 0 { // 向上滑动，main 优先
            if mainScrollView.contentOffset.y < mainScrollView.maxContentOffsetY {
                self.scrollView.contentOffset = self.scrollView.lastContentOffset
            }
            mainScrollView.lastContentOffset = mainScrollView.contentOffset
            return
        }
        
        // MARK: - 惯性滚动
        guard let decelerateVelocity = self.scrollView.decelerateVelocity else { return }
        if decelerateVelocity.y < 0 { // 向下滑动，sub 优先
            if scrollView.contentOffset.y > 0 {
                mainScrollView.contentOffset = mainScrollView.lastContentOffset
                self.scrollView.lastContentOffset = scrollView.contentOffset
            } else if scrollView.contentOffset.y == 0 {
                self.scrollView.lastContentOffset = scrollView.contentOffset
            } else {
                if mainScrollView.contentOffset.y > 0 {
                    self.scrollView.contentOffset.y = 0
                }
            }
        }
        if decelerateVelocity.y > 0 { // 向上滑动，main 优先
            if mainScrollView.contentOffset.y < mainScrollView.maxContentOffsetY {
                self.scrollView.contentOffset = self.scrollView.lastContentOffset
            }
            mainScrollView.lastContentOffset = mainScrollView.contentOffset
            return
        }
    }
    
}
