//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - Supplementary

extension CompositionalLayout {
    
    struct Supplementary: Element {
        
        enum Offset {
            case absolute(CGPoint)
            case fractional(CGPoint)
        }
        
        let layoutSize: NSCollectionLayoutSize
        let kind: String
        let alignment: NSDirectionalRectEdge
        let offset: Offset // 对齐之后，进行偏移; 只会影响位置，不会影响 cell 布局；
        
        var contentInsets: NSDirectionalEdgeInsets = .zero
        var zIndex: Int = 0
        
        init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            kind: String,
            alignment: NSDirectionalRectEdge,
            offset: Offset
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.kind = kind
            self.alignment = alignment
            self.offset = offset
        }
        
        var value: NSCollectionLayoutSupplementaryItem {
            let containerAnchor: NSCollectionLayoutAnchor = {
                switch offset {
                case .absolute(let point):
                    return .init(edges: alignment, absoluteOffset: point)
                case .fractional(let point):
                    return .init(edges: alignment, fractionalOffset: point)
                }
            }()
            let result = NSCollectionLayoutSupplementaryItem(
                layoutSize: layoutSize,
                elementKind: kind,
                containerAnchor: containerAnchor
            )
            result.contentInsets = contentInsets
            result.zIndex = zIndex
            return result
        }
        
    }
    
}

// MARK: - Item

extension CompositionalLayout {
    
    struct Item: ItemConvertible {
        
        let layoutSize: NSCollectionLayoutSize
        let supplementaries: [Supplementary]
        
        var contentInsets: NSDirectionalEdgeInsets = .zero
        
        init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.supplementaries = []
        }
        
        init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            @ElementBuilder<Supplementary> supplementaries: () -> [Supplementary]
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.supplementaries = supplementaries()
        }
        
        var value: NSCollectionLayoutItem {
            let result = NSCollectionLayoutItem(
                layoutSize: layoutSize,
                supplementaryItems: supplementaries.map({ $0.value })
            )
            result.contentInsets = contentInsets
            return result
        }
        
    }
    
}
