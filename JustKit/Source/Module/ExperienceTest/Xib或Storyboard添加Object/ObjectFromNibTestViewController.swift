//
//  Created by 姚旭 on 2022/8/8.
//

import UIKit

class ObjectFromNibTestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Xib或Storyboard添加Object"
        
        let config = TestConfigModel()
        config.topImage = UIImage(named: "tabbar-item-mine")
        config.num = 88
        config.bottomImage = UIImage(named: "tabbar-item-home")
        let testView = TestStarView(frame: CGRect(x: 10, y: 100, width: 400, height: 80), config: config)
        testView.backgroundColor = .red
        view.addSubview(testView)

    }

}
