//
//  Created by 姚旭 on 2021/4/10.
//

import UIKit

class ExperienceHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView()
    let titleList = [
        "系统原生导航栏、分栏设置说明（陈旧）", "评论类似的显示和隐藏输入框",
        "系统原生分享", "文件预览、打开、分享",
        "UIPageViewController", "悬浮可滑动按钮",
        "实时检测输入框是否合法", "循环动画旋转适配(扫描动画测试)",
        "UIScrollView包含多输入框键盘UI处理", "自定义MainWindow和统一弹窗管理",
        "自定义相机并模仿系统相机旋转逻辑", "自定义 UICollectionViewFlowLayout",
        "原生UICollectionView拖动动画", "Xib或Storyboard添加Object",
        "UIScrollView 嵌套", "UICollectionView新布局方式和数据源",
    ]
    
    // MARK: - life cirle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemGroupedBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let frame = CGRect.init(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top, width: view.bounds.size.width - view.safeAreaInsets.left - view.safeAreaInsets.right, height: view.bounds.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        tableView.frame = frame
    }
    
    // MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = titleList[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            navigationController?.pushViewController(BarTestViewController(), animated: true)
            return
        }
        if indexPath.row == 1 {
            navigationController?.pushViewController(InputShowAndHideTestViewController(), animated: true)
            return
        }
        if indexPath.row == 2 {
            navigationController?.pushViewController(SystemShareViewController(), animated: true)
            return
        }
        if indexPath.row == 3 {
            navigationController?.pushViewController(FileOpeningViewController(), animated: true)
            return
        }
        if indexPath.row == 4 {
            navigationController?.pushViewController(PageTestViewController(), animated: true)
            return
        }
        if indexPath.row == 5 {
            navigationController?.pushViewController(SuspensionViewController(), animated: true)
            return
        }
        if indexPath.row == 6 {
            navigationController?.pushViewController(InputTestViewController(), animated: true)
            return
        }
        if indexPath.row == 7 {
            navigationController?.pushViewController(ScanAnimationTestViewController(), animated: true)
            return
        }
        if indexPath.row == 8 {
            navigationController?.pushViewController(ScrollViewKeyboardTestViewController(), animated: true)
            return
        }
        if indexPath.row == 9 {
            navigationController?.pushViewController(UnifiedPopupViewController(), animated: true)
            return
        }
        if indexPath.row == 10 {
            navigationController?.pushViewController(CustomCameraViewController(), animated: true)
            return
        }
        if indexPath.row == 11 {
            navigationController?.pushViewController(FLowLayoutTestViewController(), animated: true)
            return
        }
        if indexPath.row == 12 {
            navigationController?.pushViewController(CollectionViewPanTestViewController(), animated: true)
            return
        }
        if indexPath.row == 13 {
            navigationController?.pushViewController(ObjectFromNibTestViewController(), animated: true)
            return
        }
        if indexPath.row == 14 {
            navigationController?.pushViewController(MultipleViewController(), animated: true)
            return
        }
        if indexPath.row == 15 {
            navigationController?.pushViewController(NewCollectionViewController(), animated: true)
            return
        }
    }
    
}
