//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
    struct Group: ItemConvertible {
        
        enum Axis {
            case horizontal
            case vertical
        }
        
        let axis: Axis
        let layoutSize: NSCollectionLayoutSize
        let subitems: [any ItemConvertible]
        
        var contentInsets: NSDirectionalEdgeInsets = .zero
        var interItemSpacing: NSCollectionLayoutSpacing?
        
        init(
            axis: Axis = .horizontal,
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            @ItemConvertibleBuilder subitems: () -> [any ItemConvertible]
        ) {
            self.axis = axis
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.subitems = subitems()
        }
        
        var value: NSCollectionLayoutGroup {
            let result: NSCollectionLayoutGroup
            switch axis {
            case .horizontal:
                result = NSCollectionLayoutGroup.horizontal(
                    layoutSize: layoutSize,
                    subitems: subitems.map({ $0.value })
                )
            case .vertical:
                result = NSCollectionLayoutGroup.vertical(
                    layoutSize: layoutSize,
                    subitems: subitems.map({ $0.value })
                )
            }
            result.contentInsets = contentInsets
            result.interItemSpacing = interItemSpacing
            return result
        }
        
    }
    
}
