//
//  Created by 姚旭 on 2021/12/4.
//

import UIKit

class InputTestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var testInputView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "实时检测输入框是否合法"
        testInputView.delegate = self
        testInputView.addTarget(self, action: #selector(inputViewValueDidChanged(_:)), for: .editingChanged)
    }

    /// text 通过输入真正变化时回调
    /// 对应 editing changed 事件
    @objc func inputViewValueDidChanged(_ sender: UITextField) {
        print("text = \(sender.text ?? "空")")
    }
    
    /// 输入将要变化时，判断是否合法决定是否允许变化
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let willString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        // 例如检测是否是数字
        let rules = "^[0-9]+$"
        let predicate = NSPredicate(format: "SELF matches %@", rules)
        return predicate.evaluate(with: willString)
    }

}
