//
//  Created by 姚旭 on 2022/6/29.
//

import UIKit

// MARK: - 改变位置

public extension UIView {
    
    var top: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    var left: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    var bottom: CGFloat {
        get { frame.origin.y + frame.size.height }
        set { frame.origin.y = newValue - frame.size.height }
    }

    var right: CGFloat {
        get { frame.origin.x + frame.size.width }
        set { frame.origin.x = newValue - frame.size.width }
    }

    var centerX: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    var centerY: CGFloat {
        get { center.y }
        set { center.y = newValue }
    }

    var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
}

// MARK: - 改变尺寸

public extension UIView {

    var width: CGFloat {
        get { frame.size.width }
        set { frame.size.width = newValue }
    }

    var height: CGFloat {
        get { frame.size.height }
        set { frame.size.height = newValue }
    }

    var size: CGSize {
        get { frame.size }
        set { frame.size = newValue }
    }

}
