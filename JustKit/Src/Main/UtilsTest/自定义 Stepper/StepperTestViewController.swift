//
//  Created by 姚旭 on 2022/7/5.
//

import UIKit

class StepperTestViewController: UIViewController {

    @IBOutlet weak var testStepper: Stepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "自定义 Stepper"
        
        testStepper.onClickDecrementWhenMin = { value in
            print("---------")
        }
        testStepper.onClickIncrementWhenMax = { value in
            print("+++++++++")
        }
        testStepper.onValueDidChangeHandler = { value in
            print("改为：\(value)")
        }
        testStepper.onClickValue = { value in
            print("点击了当前值：\(value)，可以试图让用户输入修改 value")
        }
        
    }

}
