//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
    public struct Group: ItemConvertible {
        
        public enum Axis {
            case horizontal
            case vertical
        }
        
        public let axis: Axis
        public let layoutSize: NSCollectionLayoutSize
        public let subitems: [any ItemConvertible]
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        public var interItemSpacing: NSCollectionLayoutSpacing?
        
        public init(
            axis: Axis = .horizontal,
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            @ItemConvertibleBuilder subitems: () -> [any ItemConvertible]
        ) {
            self.axis = axis
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.subitems = subitems()
        }
        
        public var value: NSCollectionLayoutGroup {
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