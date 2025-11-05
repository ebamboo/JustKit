//
//  Created by 姚旭 on 2021/11/26.
//

import UIKit

class ServiceHomeViewController: UIViewController {
    
    let titles = ["FlowImageView", "Browser Swift", "Browser OC", "Media View", "ScrollView简单嵌套"]
    
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

extension ServiceHomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = titles[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            navigationController?.pushViewController(FlowImageViewController(), animated: true)
            return
        }
        if indexPath.row == 1 {
            navigationController?.pushViewController(BrowserTestSwiftViewController(), animated: true)
            return
        }
        if indexPath.row == 2 {
            navigationController?.pushViewController(BrowserTestOCViewController(), animated: true)
            return
        }
        if indexPath.row == 3 {
            navigationController?.pushViewController(MediaViewTestViewController(), animated: true)
            return
        }
        if indexPath.row == 4 {
            navigationController?.pushViewController(NestedScrollViewTestViewController(), animated: true)
            return
        }
    }
    
}
