//
//  Created by 姚旭 on 2021/11/26.
//

import UIKit

class UtilsHomeViewController: UIViewController {
    
    let titles = [
        "Keychain", "ModelAnimator", "渐变视图测试",
        "自定义虚线视图DashView", "自定义UIView每个圆角大小RoundView", "仿UISwitch控件CommonSwitch",
        "UIImage+Transform 测试", "自定义 Stepper", "自定义渐变圆角边框/渐变文字",
        "标签样式CollectionViewTagLayout", "Popover弹窗工具测试", "普通视图支持上下文菜单",
        "UICollectionView新布局便利方法"
    ]
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

extension UtilsHomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = titles[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            navigationController?.pushViewController(KeychainTestViewController(), animated: true)
            return
        }
        if indexPath.row == 1 {
            navigationController?.pushViewController(PresentingViewController(), animated: true)
            return
        }
        if indexPath.row == 2 {
            navigationController?.pushViewController(GradienViewTestViewController(), animated: true)
            return
        }
        if indexPath.row == 3 {
            navigationController?.pushViewController(DashTestViewController(), animated: true)
            return
        }
        if indexPath.row == 4 {
            navigationController?.pushViewController(RoundViewTestViewController(), animated: true)
            return
        }
        if indexPath.row == 5 {
            navigationController?.pushViewController(CommonSwitchTestViewController(), animated: true)
            return
        }
        if indexPath.row == 6 {
            navigationController?.pushViewController(UIImageTransformTestViewController(), animated: true)
            return
        }
        if indexPath.row == 7 {
            navigationController?.pushViewController(StepperTestViewController(), animated: true)
            return
        }
        if indexPath.row == 8 {
            navigationController?.pushViewController(GradeTestViewController(), animated: true)
            return
        }
        if indexPath.row == 9 {
            navigationController?.pushViewController(TagLayoutTestViewController(), animated: true)
            return
        }
        if indexPath.row == 10 {
            navigationController?.pushViewController(PopoverToolsTestViewController(), animated: true)
            return
        }
        if indexPath.row == 11 {
            navigationController?.pushViewController(ContextMenuTestViewController(), animated: true)
            return
        }
        if indexPath.row == 12 {
            navigationController?.pushViewController(NSCollectionLayoutTestViewController(), animated: true)
            return
        }
    }
    
}
