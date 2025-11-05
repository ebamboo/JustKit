//
//  Created by 姚旭 on 2021/4/25.
//

import UIKit

public extension UIViewController {
    
    func presentAlert(
        title: String?,
        message: String?,
        actionsTitle: [String],
        actionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        let vc = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        for (index, actionTitle) in actionsTitle.enumerated() {
            let btn = UIAlertAction(title: actionTitle, style: .default) { action in
                actionsHandler(index, action)
            }
            vc.addAction(btn)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func presentSheet(
        title: String?,
        message: String?,
        cancelTitle: String,
        cancelHandler: @escaping (_ action: UIAlertAction) -> Void,
        optionsTitle: [String],
        optionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelBtn = UIAlertAction(title: cancelTitle, style: .cancel) { action in
            cancelHandler(action)
        }
        vc.addAction(cancelBtn)
        for (index, optionTitle) in optionsTitle.enumerated() {
            let optionBtn = UIAlertAction(title: optionTitle, style: .default) { action in
                optionsHandler(index, action)
            }
            vc.addAction(optionBtn)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func presentAlert(
        title: String?,
        message: String?,
        actionsTitle: String...,
        actionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        presentAlert(title: title,
                     message: message,
                     actionsTitle: actionsTitle,
                     actionsHandler: actionsHandler)
    }

    func presentSheet(
        title: String?,
        message: String?,
        cancelTitle: String,
        cancelHandler: @escaping (_ action: UIAlertAction) -> Void,
        optionsTitle: String...,
        optionsHandler: @escaping (_ index: Int, _ action: UIAlertAction) -> Void
    ) {
        presentSheet(title: title,
                     message: message,
                     cancelTitle: cancelTitle,
                     cancelHandler: cancelHandler,
                     optionsTitle: optionsTitle,
                     optionsHandler: optionsHandler)
    }
    
}

public extension UIViewController {
    
    func addChild(_ child: UIViewController,
                  in container: UIView,
                  layout: ((_ childView: UIView, _ container: UIView) -> Void)? = nil) {
        addChild(child)
        container.addSubview(child.view)
        if let layout = layout {
            layout(child.view, container)
        } else {
            child.view.translatesAutoresizingMaskIntoConstraints = false
            child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            child.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
    }
    
    func removeChild(_ child: UIViewController) {
        child.view.removeFromSuperview()
        child.willMove(toParent: nil)
        child.removeFromParent()
    }
    
    func removeSelf() {
        view.removeFromSuperview()
        willMove(toParent: nil)
        removeFromParent()
    }
    
}
