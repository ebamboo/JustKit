//
//  Created by 姚旭 on 2021/4/14.
//

import UIKit

class SystemShareViewController: UIViewController {

    lazy var testBtn: UIButton = {
        let view = UIButton.init(type: .custom)
        view.bounds = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        view.setTitle("share", for: .normal)
        view.backgroundColor = .gray
        view.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        return view
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        testBtn.center = view.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "系统原生分享"
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(testBtn)
    }
    
    @objc func shareAction() {
        /// 说明文档
        /// https://nshipster.com/uiactivityviewcontroller/
        /// UIActivityViewController provides a unified interface for users to share and perform actions on strings, images, URLs, and other items within an app.
        let text = "分享的文字"
        let url = URL.init(string: "https://www.baidu.com")!
        let image = UIImage.init(named: "system-share-1")!
        let activityVC = UIActivityViewController.init(activityItems: [text, url, image], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) -> Void in
            if completed {
                print("ensure")
            } else {
                print("cancel")
            }
        }
        self.present(activityVC, animated: true, completion: nil)
        
        
        // 注意 iPad 和 iPhone 模态形式
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            present(activityVC, animated: true, completion: nil)
//            return
//        }
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            let popver = activityVC.popoverPresentationController
//            popver?.sourceView = sender
//            popver?.sourceRect = sender.bounds
//            present(activityVC, animated: true, completion: nil)
//            return
//        }
    }

}
