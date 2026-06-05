//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - BoundarySupplementary

extension CompositionalLayout {
    
    struct BoundarySupplementary: Element {
        
        let layoutSize: NSCollectionLayoutSize
        let kind: String
        let alignment: NSRectAlignment
        let offset: CGPoint // 对齐之后，进行偏移; 可能会影响 section 布局，以达到不会遮盖其他 section 内容；
        
        var contentInsets: NSDirectionalEdgeInsets = .zero
        var zIndex: Int = 0 // pinToVisibleBounds 为 true 时，zIndex 无效
        var pinToVisibleBounds: Bool = false // 是否吸附
        
        init(
            width: NSCollectionLayoutDimension = .fractionalWidth(1),
            height: NSCollectionLayoutDimension = .estimated(80),
            kind: String,
            alignment: NSRectAlignment,
            offset: CGPoint = .zero
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.kind = kind
            self.alignment = alignment
            self.offset = offset
        }
        
        var value: NSCollectionLayoutBoundarySupplementaryItem {
            let result = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: layoutSize,
                elementKind: kind,
                alignment: alignment,
                absoluteOffset: offset
            )
            result.contentInsets = contentInsets
            result.zIndex = zIndex
            result.pinToVisibleBounds = pinToVisibleBounds
            return result
        }
        
    }
    
}

// MARK: - Decoration

extension CompositionalLayout {
    
    struct Decoration: Element {
        
        let kind: String
        
        var contentInsets: NSDirectionalEdgeInsets = .zero
        var zIndex: Int = 0
        
        init(
            kind: String
        ) {
            self.kind = kind
        }
        
        var value: NSCollectionLayoutDecorationItem {
            let result = NSCollectionLayoutDecorationItem.background(
                elementKind: kind
            )
            result.contentInsets = contentInsets
            result.zIndex = zIndex
            return result
        }
        
    }
    
}

// MARK: - Section

extension CompositionalLayout {
    
    struct Section: Element {
        
        let groups: [Group]
        let boundaries: [BoundarySupplementary]
        let decorations: [Decoration]
        
        var contentInsets: NSDirectionalEdgeInsets = .zero
        var interGroupSpacing: CGFloat = 0
        /// 正交方向滚动行为；须设置该属性以使 section 可正交方向滚动
        var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none
        
        init(
            @ElementBuilder<Group> groups: () -> [Group]
        ) {
            self.groups = groups()
            self.boundaries = []
            self.decorations = []
        }
        
        init(
            @ElementBuilder<Group> groups: () -> [Group],
            @ElementBuilder<BoundarySupplementary> boundaries: () -> [BoundarySupplementary]
        ) {
            self.groups = groups()
            self.boundaries = boundaries()
            self.decorations = []
        }
        
        init(
            @ElementBuilder<Group> groups: () -> [Group],
            @ElementBuilder<Decoration> decorations: () -> [Decoration]
        ) {
            self.groups = groups()
            self.boundaries = []
            self.decorations = decorations()
        }
        
        init(
            @ElementBuilder<Group> groups: () -> [Group],
            @ElementBuilder<BoundarySupplementary> boundaries: () -> [BoundarySupplementary],
            @ElementBuilder<Decoration> decorations: () -> [Decoration]
        ) {
            self.groups = groups()
            self.boundaries = boundaries()
            self.decorations = decorations()
        }
        
        var value: NSCollectionLayoutSection {
            guard let group = groups.first else { fatalError("section 中必须定义 group") }
            let result: NSCollectionLayoutSection = .init(group: group.value)
            result.boundarySupplementaryItems = boundaries.map({ $0.value })
            result.decorationItems = decorations.map({ $0.value })
            result.contentInsets = contentInsets
            result.interGroupSpacing = interGroupSpacing
            result.orthogonalScrollingBehavior = orthogonalScrollingBehavior
            return result
        }
        
    }
    
}
