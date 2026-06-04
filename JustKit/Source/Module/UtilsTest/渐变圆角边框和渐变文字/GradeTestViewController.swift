//
//  Created by 姚旭 on 2022/7/7.
//

import UIKit

class GradeTestViewController: UIViewController {

    @IBOutlet weak var border: GradientBorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        border.colors = [
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor.red
                } else {
                    return UIColor.blue
                }
            },
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor.orange
                } else {
                    return UIColor.orange
                }
            },
            UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return UIColor.blue
                } else {
                    return UIColor.red
                }
            },
        ]
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
