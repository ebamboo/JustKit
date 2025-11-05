//
//  Created by 姚旭 on 2022/9/26.
//

import UIKit

class TableChildViewController: UIViewController {

    var mainScrollView: MainScrollView!
    @IBOutlet weak var tableView: SubTableView!
    
    @IBOutlet weak var indexLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mainScrollView = mainScrollView
    }

}

extension TableChildViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 36
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.backgroundColor = .systemGray3
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        }
        cell?.textLabel?.text = "第\(indexPath.section + 1)项"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    // MARK: - 核心
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.tableView.decelerateVelocity = velocity
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.tableView.lastContentOffset = scrollView.contentOffset
            self.tableView.decelerateVelocity = nil
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tableView.lastContentOffset = scrollView.contentOffset
        self.tableView.decelerateVelocity = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        defer {
            if let topIndexPath = tableView.indexPathForRow(at: CGPoint(x: tableView.bounds.size.width/2, y: tableView.contentOffset.y + 1)) {
                indexLabel.text = "第\n\(topIndexPath.section+1)\n组"
            } else if let topIndexPath = tableView.indexPathForRow(at: CGPoint(x: tableView.bounds.size.width/2, y: tableView.contentOffset.y + (1 + 10))) { // 4 为 section 间距
                indexLabel.text = "第\n\(topIndexPath.section+1)\n组"
            }
        }
        
        guard let mainScrollView = self.mainScrollView else { return }
        
        // MARK: - 拖拽滚动
        let dragVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView)
        if dragVelocity.y > 0 { // 向下滑动，sub 优先
            if scrollView.contentOffset.y > 0 {
                mainScrollView.contentOffset = mainScrollView.lastContentOffset
                self.tableView.lastContentOffset = scrollView.contentOffset
            } else if scrollView.contentOffset.y == 0 {
                self.tableView.lastContentOffset = scrollView.contentOffset
            } else {
                if mainScrollView.contentOffset.y > 0 {
                    self.tableView.contentOffset.y = 0
                }
            }
            return
        }
        if dragVelocity.y < 0 { // 向上滑动，main 优先
            if mainScrollView.contentOffset.y < mainScrollView.maxContentOffsetY {
                self.tableView.contentOffset = self.tableView.lastContentOffset
            }
            mainScrollView.lastContentOffset = mainScrollView.contentOffset
            return
        }
        
        // MARK: - 惯性滚动
        guard let decelerateVelocity = self.tableView.decelerateVelocity else { return }
        if decelerateVelocity.y < 0 { // 向下滑动，sub 优先
            if scrollView.contentOffset.y > 0 {
                mainScrollView.contentOffset = mainScrollView.lastContentOffset
                self.tableView.lastContentOffset = scrollView.contentOffset
            } else if scrollView.contentOffset.y == 0 {
                self.tableView.lastContentOffset = scrollView.contentOffset
            } else {
                if mainScrollView.contentOffset.y > 0 {
                    self.tableView.contentOffset.y = 0
                }
            }
            return
        }
        if decelerateVelocity.y > 0 { // 向上滑动，main 优先
            if mainScrollView.contentOffset.y < mainScrollView.maxContentOffsetY {
                self.tableView.contentOffset = self.tableView.lastContentOffset
            }
            mainScrollView.lastContentOffset = mainScrollView.contentOffset
            return
        }
    }
    
}
