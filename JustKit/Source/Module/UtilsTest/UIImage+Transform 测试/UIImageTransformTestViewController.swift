//
//  Created by 姚旭 on 2022/7/5.
//

import UIKit

class UIImageTransformTestViewController: UIViewController {
    
    @IBOutlet weak var originImageView: UIImageView!
    @IBOutlet weak var testImageView01: UIImageView!
    @IBOutlet weak var testImageView02: UIImageView!
    
    let testImage = UIImage(named: "02")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "UIImage+Transform 测试"
        originImageView.image = testImage
        testImageView01.image = testImage
        testImageView02.image = testImage
    }

    static var i = 0
    /// 测试四个方向旋转（0°、90°、180°、270°）
    @IBAction func testAction01(_ sender: Any) {
        let angle = CGFloat.pi / 2 * CGFloat(Self.i % 4)
        testImageView01.image = testImage.rotated(by: angle)
        Self.i += 1
    }
    
    static var j = 0
    /// 测试多种变换组合
    @IBAction func testAction02(_ sender: Any) {
        switch Self.j % 5 {
        case 0:
            // 任意角度旋转（20°）
            testImageView02.image = testImage.rotated(by: .pi / 9)
        case 1:
            // 水平镜像（左右翻转）
            testImageView02.image = testImage.rotated(by: 0, mirrored: true)
        case 2:
            // 上下翻转 = 水平镜像 + 旋转 180°
            testImageView02.image = testImage.rotated(by: .pi, mirrored: true)
        case 3:
            // 镜像 + 90° 旋转
            testImageView02.image = testImage.rotated(by: .pi / 2, mirrored: true)
        case 4:
            // 任意角度旋转（-45°，逆时针）
            testImageView02.image = testImage.rotated(by: -.pi / 4)
        default:
            break
        }
        Self.j += 1
    }
    
    @IBAction func restartAction(_ sender: Any) {
        testImageView01.image = testImage
        testImageView02.image = testImage
    }
    
}
