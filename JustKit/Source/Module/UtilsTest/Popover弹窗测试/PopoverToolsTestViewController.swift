//
//  Created by 姚旭 on 2025/8/14.
//

import UIKit

class PopoverToolsTestViewController: UIViewController {
    
    class MyTestViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .red
            preferredContentSize = .init(width: 200, height: 200)
        }
    }
    
    @IBAction func testAction1(_ sender: UIButton) {
        let vc = MyTestViewController()
        showPopoverMenu(vc, sourceView: sender)
    }
    
    @IBAction func testAction2(_ sender: UIButton) {
        let vc = MyTestViewController()
        showPopoverMenu(vc,
                        sourceView: sender,
                        permittedArrowDirections: .any,
                        popoverBackgroundViewClass: NoneArrowPopoverBackgroundView<NoneArrowPopoverBackgroundViewDefaultSpacing>.self)
    }
    
}
