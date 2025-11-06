//
//  Created by 姚旭 on 2021/4/14.
//

import UIKit

class SystemShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "系统原生分享"
        view.backgroundColor = .systemGroupedBackground
        
        let testBtn = UIButton.init(type: .custom)
        testBtn.frame = CGRect.init(x: 100, y: 200, width: 100, height: 44)
        testBtn.setTitle("share", for: .normal)
        testBtn.backgroundColor = .gray
        testBtn.addTarget(self, action: #selector(shareAction(sender:)), for: .touchUpInside)
        view.addSubview(testBtn)
    }
    
    @objc func shareAction(sender: UIButton) {
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
        
        // 注意 iPad 和 iPhone 模态形式
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(activityVC, animated: true, completion: nil)
            return
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popver = activityVC.popoverPresentationController
            popver?.sourceView = sender
            popver?.sourceRect = sender.bounds
            present(activityVC, animated: true, completion: nil)
            return
        }
    }

}
