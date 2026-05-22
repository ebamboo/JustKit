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
            testView.customContextMenu = testMenu
        }
    }
    
    lazy var testMenu = {
        let edit = UIAction(title: "编辑") { _ in print("编辑") }
        let delete = UIAction(title: "删除", attributes: .destructive) { _ in print("删除") }
        let menu = UIMenu(children: [edit, delete])
        return menu
    }()
    
}
