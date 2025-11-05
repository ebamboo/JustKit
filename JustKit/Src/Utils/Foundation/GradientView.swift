//
//  Created by 姚旭 on 2025/10/16.
//

import UIKit

class GradientView: UIView {
    
    override var layer: CAGradientLayer {
        super.layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
}
