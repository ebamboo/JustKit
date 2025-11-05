//
//  Created by 姚旭 on 2025/10/12.
//

import UIKit
import Combine

class InputShowAndHideTestViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: TestTextField! {
        didSet {
            inputTextField.onActive = { [weak self] isActive in
                guard let self else { return }
                self.inputBottom.isActive = isActive
            }
        }
    }
    
    // 注意此处是强引用，如果是弱引用会立刻释放该约束
    @IBOutlet var inputBottom: NSLayoutConstraint! {
        didSet {
            inputBottom.isActive = false
        }
    }
    
    @IBAction func commentAction(_ sender: Any) {
        inputTextField.becomeFirstResponder()
    }
    
    @IBAction func closeKeyboardAction(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
    
}

class TestTextField: UITextField {
    
    // 唤起键盘时，根据键盘布局，收齐键盘时不根据键盘布局
    var onActive: ((_ isActive: Bool) -> Void)?
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        onActive?(true)
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        onActive?(false)
        return super.resignFirstResponder()
    }
    
}
