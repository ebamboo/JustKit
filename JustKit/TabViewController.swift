//
//  Created by 姚旭 on 2024/12/14.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vcInfoList: [(vc: UIViewController, title: String)] = [
            (UtilsHomeViewController(), "通用工具"),
            (ServiceHomeViewController(), "项目工具"),
            (ExperienceHomeViewController(), "经验方案"),
        ]
        vcInfoList.forEach { couple in
            couple.vc.tabBarItem = UITabBarItem(title: couple.title, image: nil, selectedImage: nil)
        }
        viewControllers = vcInfoList.map({ $0.vc })
        
    }

}
