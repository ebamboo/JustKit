//
//  Created by 姚旭 on 2023/8/11.
//

import UIKit

public extension UIStackView {
    
    /// 移除所有已排列的子视图，同时将其从视图层级中移除
    func removeAllArrangedSubviews () {
        let itemViewList = arrangedSubviews
        itemViewList.forEach { itemView in
            removeArrangedSubview(itemView)
            itemView.removeFromSuperview()
        }
    }
    
}
