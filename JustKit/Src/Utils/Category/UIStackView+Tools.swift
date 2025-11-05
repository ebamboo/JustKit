//
//  Created by 姚旭 on 2023/8/11.
//

import UIKit

public extension UIStackView {
    
    func removeAllArrangedSubviews () {
        let itemViewList = arrangedSubviews
        itemViewList.forEach { itemView in
            removeArrangedSubview(itemView)
            itemView.removeFromSuperview()
        }
    }
    
}
