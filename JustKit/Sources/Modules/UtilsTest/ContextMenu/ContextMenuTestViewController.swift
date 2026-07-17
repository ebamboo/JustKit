//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

class ContextMenuTestViewController: UIViewController {

    @IBOutlet weak var testBtn: UIButton! {
        didSet {
            if #available(iOS 14.0, *) {
                testBtn.menu = testMenu
                testBtn.showsMenuAsPrimaryAction = true
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBOutlet weak var testView: UIView! {
        didSet {
            testView.contextMenu = testMenu
        }
    }
    
    
    @IBOutlet weak var testEditLabel: UILabel! {
        didSet {
            if #available(iOS 16.0, *) {
                testEditLabel.editMenu = testEditMenu
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    lazy var testMenu = {
        let edit = UIAction(title: "编辑") { _ in print("编辑") }
        let delete = UIAction(title: "删除", attributes: .destructive) { _ in print("删除") }
        let menu = UIMenu(children: [edit, delete])
        return menu
    }()
    
    lazy var testEditMenu = {
        let copy = UIAction(title: "自定义拷贝") { _ in print("拷贝") }
        let select = UIAction(title: "自定义选择") { _ in print("选择") }
        let pase = UIAction(title: "自定义粘贴") { _ in print("粘贴") }
        let edit = UIAction(title: "自定义编辑") { _ in print("编辑") }
        let delete = UIAction(title: "自定义删除", attributes: .destructive) { _ in print("删除") }
        let menu = UIMenu(children: [copy, select, pase, edit, delete])
        return menu
    }()
    
}
