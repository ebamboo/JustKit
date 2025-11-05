//
//  Created by 姚旭 on 2021/4/14.
//

import UIKit

class PageTestViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    var pageVC: UIPageViewController!
    let vcs = [PageViewController01(), PageViewController02(), PageViewController03()]
    @IBOutlet weak var indexLabel: UILabel!
    var currentIndex = 0 {
        didSet {
            indexLabel.text = String.init(currentIndex)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageVC.view.frame = contentView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIPageViewController"
        
        /// TransitionStyle：书本翻页风格和 Scroll 风格
        /// NavigationOrientation 水平方向和垂直方向
        /// OptionsKey：
        /// spineLocation 表示书脊位置，取值范围 SpineLocation，注意只有 pageCurl 效果时有效
        /// interPageSpacing 表示视图直接的间距，注意只有 scroll 效果时有效
        ///
        /// 实现 dataSource 两个重要方法可以实现手势切换页面
        /// 实现 delegate 相关方法可以获取当前展示的 vc 页面
        ///
        
        pageVC = UIPageViewController.init(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
        pageVC.dataSource = self
        pageVC.delegate = self
        self.addChild(pageVC)
        contentView.addSubview(pageVC.view)
        pageVC.setViewControllers([vcs[currentIndex]], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = vcs.firstIndex(of: viewController)!
        if index == 0 {
            return nil
        } else {
            return vcs[index-1]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = vcs.firstIndex(of: viewController)!
        if index == vcs.count-1 {
            return nil
        } else {
            return vcs[index+1]
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let showingVC = pageViewController.viewControllers!.first!
        currentIndex = vcs.firstIndex(of: showingVC)!
    }
    
    // MARK: - actions
    
    @IBAction func backAction(_ sender: Any) {
        if currentIndex > 0 {
            currentIndex -= 1
            pageVC.setViewControllers([vcs[currentIndex]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
        }
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        if currentIndex < vcs.count-1 {
            currentIndex += 1
            pageVC.setViewControllers([vcs[currentIndex]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
    }
    
}
