//
//  Created by 姚旭 on 2024/12/14.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vcInfoList: [(vc: UIViewController, title: String)] = [
            (ExperienceHomeViewController(), "经验方案"),
            (ServiceHomeViewController(), "项目工具"),
            (UtilsHomeViewController(), "通用工具"),
        ]
        vcInfoList.forEach { couple in
            couple.vc.tabBarItem = UITabBarItem(title: couple.title, image: nil, selectedImage: nil)
        }
        viewControllers = vcInfoList.map({ $0.vc })
        
    }

}
