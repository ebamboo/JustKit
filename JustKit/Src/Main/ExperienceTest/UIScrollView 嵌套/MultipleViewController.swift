//
//  Created by 姚旭 on 2022/9/26.
//

import UIKit

class MultipleViewController: UIViewController {

    @IBOutlet weak var scrollView: MainScrollView!
    @IBOutlet weak var scrollBtn: UIButton!
    @IBOutlet weak var tableBtn: UIButton!
    var pageVC: UIPageViewController!
    @IBOutlet weak var subcontentBack: UIView!
    lazy var vcs: [UIViewController] = {
        let vc1 = ScrollChildViewController()
        vc1.mainScrollView = self.scrollView
        let vc2 = TableChildViewController()
        vc2.mainScrollView = self.scrollView
        return [vc1, vc2]
    }()
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [.interPageSpacing: 10])
        pageVC.dataSource = self
        pageVC.delegate = self
        self.addChild(pageVC)
        subcontentBack.addSubview(pageVC.view)
        pageVC.setViewControllers([vcs[currentIndex]], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageVC.view.frame = subcontentBack.bounds
    }

    @IBAction func selectScrollAction(_ sender: UIButton) {
        if sender.isSelected { return }
        sender.isSelected = true
        tableBtn.isSelected = false
        currentIndex = 0
        pageVC.setViewControllers([vcs[currentIndex]], direction: .reverse, animated: true, completion: nil)
    }
    
    @IBAction func selectTableAction(_ sender: UIButton) {
        if sender.isSelected { return }
        sender.isSelected = true
        scrollBtn.isSelected = false
        currentIndex = 1
        pageVC.setViewControllers([vcs[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
}

extension MultipleViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
    
}

// MARK: - 核心

extension MultipleViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollView.lastContentOffset = scrollView.contentOffset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollView.lastContentOffset = scrollView.contentOffset
    }
    
}
