//
//  Created by 姚旭 on 2021/4/15.
//

import UIKit

class SuspensionViewController: UIViewController {

    var suspensionView: UIView!
    var suspensionViewLoactionInSuperView = CGPoint.init(x: 0.1, y: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "悬浮滑动按钮"
        view.backgroundColor = .systemGroupedBackground
        
        ///
        /// 核心思路：给 suspensionView 添加 UIPanGestureRecognizer 手势实时更新 suspensionView.center
        /// 要在一定“安全区域”内进行滑动
        /// 可以给 suspensionView 添加事件处理一些事情
        ///
        
        suspensionView = UIView.init(frame: .init(x: 0, y: 0, width: 60, height: 60))
        suspensionView.clipsToBounds = true
        suspensionView.layer.cornerRadius = 30;
        suspensionView.backgroundColor = .red
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        suspensionView.addGestureRecognizer(pan)
        view.addSubview(suspensionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let center = CGPoint.init(
            x: view.bounds.size.width * suspensionViewLoactionInSuperView.x,
            y: view.bounds.size.height * suspensionViewLoactionInSuperView.y
        )
        suspensionView.center = center;
    }
    
    @objc func panAction(pan: UIPanGestureRecognizer) -> Void {
        let location = pan.location(in: view)
        let safeArea = view.safeAreaLayoutGuide.layoutFrame
        if safeArea.contains(location) {
            suspensionView.center = location;
            suspensionViewLoactionInSuperView = CGPoint.init(
                x: location.x / view.bounds.size.width,
                y: location.y / view.bounds.size.height
            )
        }
    }
    
}
