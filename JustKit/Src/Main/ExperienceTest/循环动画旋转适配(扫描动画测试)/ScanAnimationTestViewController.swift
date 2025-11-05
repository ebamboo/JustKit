//
//  Created by 姚旭 on 2025/10/17.
//

import UIKit

class ScanAnimationTestViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    var animation: CAAnimation {
        let ani = CABasicAnimation(keyPath: "position")
        ani.fromValue = CGPoint.init(x: view.bounds.width/2, y: 50)
        ani.toValue = CGPoint.init(x: view.bounds.width/2, y: view.bounds.height-50)
        ani.duration = 2
        ani.repeatCount = .infinity
        ani.timingFunction = .init(name: .default)
        return ani
    }
    
    // 将要布局子视图时移除子视图的动画
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        animationView.layer.removeAnimation(forKey: "scan")
    }
    
    // 等子视图已更新布局完毕，根据条件是否需要添加动画
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animationView.layer.add(animation, forKey: "scan")
    }
    
}
