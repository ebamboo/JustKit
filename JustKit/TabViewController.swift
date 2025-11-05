//
//  Created by 姚旭 on 2024/12/14.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vcInfoList: [(vc: UINavigationController, title: String)] = [
            (UINavigationController(rootViewController: UtilsTestViewController()), "Utils"),
            (UINavigationController(rootViewController: ToolsTestViewController()), "Tools"),
        ]
        vcInfoList.forEach { couple in
            couple.vc.tabBarItem = UITabBarItem(title: couple.title, image: nil, selectedImage: nil)
        }
        viewControllers = vcInfoList.map({ $0.vc })
        
    }

}
