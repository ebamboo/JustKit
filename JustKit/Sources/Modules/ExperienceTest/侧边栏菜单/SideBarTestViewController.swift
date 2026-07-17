//
//  Created on 2026/7/2.
//

import UIKit

class SideBarTestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "侧边栏菜单"
        view.backgroundColor = .systemGroupedBackground
        
        // 主视图内容
        let openButton = UIButton(type: .system)
        openButton.setTitle("打开侧边栏", for: .normal)
        openButton.titleLabel?.font = .systemFont(ofSize: 18)
        openButton.addTarget(self, action: #selector(openSideBar), for: .touchUpInside)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openButton)
        NSLayoutConstraint.activate([
            openButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func openSideBar() {
        let mainVC = SideBarMainViewController()
        let menuVC = SideBarMenuViewController()
        var config = SideBarConfiguration()
        config.menuDisplayMode = .push
        let sideBarVC = SideBarController(main: mainVC, menu: menuVC, configuration: config)
        sideBarVC.modalPresentationStyle = .fullScreen
        present(sideBarVC, animated: true)
    }
    
}

// MARK: - 演示用主视图控制器

private class SideBarMainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let menuButton = UIButton(type: .system)
        menuButton.setTitle("☰ 菜单", for: .normal)
        menuButton.titleLabel?.font = .systemFont(ofSize: 20)
        menuButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuButton)
        
        let label = UILabel()
        label.text = "主视图内容区域\n左边缘滑动或点击按钮打开菜单"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            menuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func toggleMenu() {
        if let sideBar = parent as? SideBarController {
            sideBar.toggleMenu()
        }
    }
    
}

// MARK: - 演示用菜单视图控制器

private class SideBarMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let items = ["首页", "个人中心", "设置", "关于", "退出"]
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 选中菜单项后关闭侧边栏
        if let sideBar = parent as? SideBarController {
            sideBar.toggleMenu()
        }
    }
    
}
