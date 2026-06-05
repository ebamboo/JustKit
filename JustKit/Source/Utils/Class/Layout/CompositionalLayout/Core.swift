//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

enum CompositionalLayout {
    
    protocol Element {
        func configured(_ block: (inout Self) -> Void) -> Self
    }
    
    protocol ItemConvertible: Element {
        associatedtype Value: NSCollectionLayoutItem
        var value: Value { get }
    }
    
}

extension CompositionalLayout.Element {
    
    func configured(_ block: (inout Self) -> Void) -> Self {
        var copy = self;  block(&copy); return copy
    }
    
}

extension CompositionalLayout {
    
}
