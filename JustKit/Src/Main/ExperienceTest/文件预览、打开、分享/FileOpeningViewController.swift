//
//  Created by 姚旭 on 2021/4/14.
//

import UIKit

class FileOpeningViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    /// 延长生命周期
    var documentVC: UIDocumentInteractionController?
    
    lazy var imageBtn: UIButton = {
        let view = UIButton.init(type: .custom)
        view.bounds = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        view.setTitle("图片", for: .normal)
        view.backgroundColor = .gray
        view.addTarget(self, action: #selector(imageAction), for: .touchUpInside)
        return view
    }()
    
    lazy var fileBtn: UIButton = {
        let view = UIButton.init(type: .custom)
        view.bounds = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        view.setTitle("文件", for: .normal)
        view.backgroundColor = .gray
        view.addTarget(self, action: #selector(fileAction), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var imageCenter = view.center
        imageCenter.y = imageCenter.y - 100
        imageBtn.center = imageCenter
        fileBtn.center = view.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "文件预览、打开、分享"
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(imageBtn)
        view.addSubview(fileBtn)
    }

    @objc func imageAction() {
        let url = Bundle.main.url(forResource: "test_picture_url", withExtension: ".jpg")!
        documentVC = UIDocumentInteractionController.init(url: url)
        documentVC?.delegate = self
        
        /// presentPreview 该方法直接调用预览功能
        documentVC?.presentPreview(animated: true)
    }
    
    @objc func fileAction() {
        
        let url = Bundle.main.url(forResource: "test_file_url", withExtension: ".pdf")!
        documentVC = UIDocumentInteractionController.init(url: url)
        documentVC?.delegate = self
        
        ///
        /// 1、presentOptionsMenu
        /// This is the default method you should call to give your users the option to quick look, open, or copy the document.
        /// Presents a menu allowing the user to Quick Look, open, or copy the item specified by URL.
        /// This automatically determines the correct application or applications that can open the item at URL.
        /// Returns NO if the options menu contained no options and was not opened.
        /// 2、presentOpenInMenu
        /// Presents a menu allowing the user to open the document in another application.
        /// The menu will contain all applications that can open the item at URL
        /// Returns NO if there are no applications that can open the item at URL.
        ///
        documentVC?.presentOptionsMenu(from: fileBtn.bounds, in: fileBtn, animated: true)
    }
    
    // MARK: - UIDocumentInteractionControllerDelegate
    
    // 预览功能必须实现的代理方法
    // 无论直接调用预览还是从菜单预览都必须实现才行
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}
