//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - Supplementary

extension CompositionalLayout {
    
    public struct Supplementary: Element {
        
        public enum Offset {
            case absolute(CGPoint)
            case fractional(CGPoint)
        }
        
        public let layoutSize: NSCollectionLayoutSize
        public let kind: String
        public let alignment: NSDirectionalRectEdge
        public let offset: Offset // 对齐之后，进行偏移; 只会影响位置，不会影响 cell 布局；
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        public var zIndex: Int = 0
        
        public init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            kind: String,
            alignment: NSDirectionalRectEdge,
            offset: Offset = .absolute(.zero)
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.kind = kind
            self.alignment = alignment
            self.offset = offset
        }
        
        public var value: NSCollectionLayoutSupplementaryItem {
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
    
    public struct Item: ItemConvertible {
        
        public let layoutSize: NSCollectionLayoutSize
        public let supplementaries: [Supplementary]
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        
        public init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.supplementaries = []
        }
        
        public init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            @ElementBuilder<Supplementary> supplementaries: () -> [Supplementary]
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.supplementaries = supplementaries()
        }
        
        public var value: NSCollectionLayoutItem {
            let result = NSCollectionLayoutItem(
                layoutSize: layoutSize,
                supplementaryItems: supplementaries.map({ $0.value })
            )
            result.contentInsets = contentInsets
            return result
        }
        
    }
    
}