//
//  Created by 姚旭 on 2025/10/16.
//

import UIKit

class GradienViewTestViewController: UIViewController {
    
    // 线性方向变化
    @IBOutlet weak var testView1: GradientView! {
        didSet {
            testView1.layer.type = .axial
            testView1.layer.startPoint = .zero
            testView1.layer.endPoint = .init(x: 1, y: 1)
            testView1.layer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        }
    }
    
    // 半径方向变化
    // startPoint 表示圆心
    // endPoint:
    // X(endPoint) - X(startPoint) 必须大于 0，且该值表示 X 半轴
    // Y(endPoint) - Y(startPoint) 必须大于 0，且该值表示 Y 半轴
    @IBOutlet weak var testView2: GradientView! {
        didSet {
            testView2.layer.type = .radial
            testView2.layer.startPoint = .init(x: 0.5, y: 0.5)
            testView2.layer.endPoint = .init(x: 0.8, y: 0.8)
            testView2.layer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.orange.cgColor]
        }
    }
    @IBOutlet weak var testView3: GradientView! {
        didSet {
            testView3.layer.type = .radial
            testView3.layer.startPoint = .init(x: 0.5, y: 0.5)
            testView3.layer.endPoint = .init(x: 1, y: 1)
            testView3.layer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.orange.cgColor]
        }
    }
    
    // 环形方向变化
    // startPoint 表示圆心
    // endPoint: 该点和startPoint连线表示半径，并从该点顺时针旋转渐变颜色
    @IBOutlet weak var testView4: GradientView! {
        didSet {
            testView4.layer.type = .conic
            testView4.layer.startPoint = .init(x: 0.5, y: 0.5)
            testView4.layer.endPoint = .init(x: 0.5, y: 0)
            testView4.layer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor]
        }
    }
    @IBOutlet weak var testView5: GradientView! {
        didSet {
            testView5.layer.type = .conic
            testView5.layer.startPoint = .init(x: 0.7, y: 0.5)
            testView5.layer.endPoint = .init(x: 0.7, y: 0)
            testView5.layer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.orange.cgColor, UIColor.red.cgColor]
        }
    }

}
