//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - base

protocol CollectionBaseSetup {
    func setup(_ block: (Self) -> Void) -> Self
}
extension CollectionBaseSetup {
    func setup(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

class CollectionBase {
    var contentInsets: NSDirectionalEdgeInsets = .zero
}
extension CollectionBase: CollectionBaseSetup {}

// MARK: - UICollectionViewLayout convenience

extension UICollectionViewCompositionalLayout {
    
    static func custom(
        _ sectionProvider: @escaping (Int, any NSCollectionLayoutEnvironment) -> CollectionSection?
    ) -> Self {
        Self.init { sectionIndex, environment in
            guard let section = sectionProvider(sectionIndex, environment) else { return nil }
            return section.realValue
        }
    }
    
}

// MARK: - components

class CollectionItem: CollectionBase {
    
    let layoutSize: NSCollectionLayoutSize
    
    init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
    }
    
    var realValue: NSCollectionLayoutItem {
        let realItem: NSCollectionLayoutItem = .init(layoutSize: layoutSize)
        realItem.contentInsets = contentInsets
        return realItem
    }
    
}

protocol CollectionGroup {
    var realValue: NSCollectionLayoutGroup { get }
}

class CollectionHGroup: CollectionBase, CollectionGroup {
    
    let layoutSize: NSCollectionLayoutSize
    let subitems: [CollectionItem]
    var interItemSpacing: NSCollectionLayoutSpacing?
    
    init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        @CollectionBuilder subitemsBuilder: () -> [CollectionBase]
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        let items = subitemsBuilder()
        let subitems = items.compactMap { item in
            item as? CollectionItem
        }
        self.subitems = subitems
    }
    
    var realValue: NSCollectionLayoutGroup {
        let realGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: layoutSize,
            subitems: subitems.map({ $0.realValue })
        )
        realGroup.contentInsets = contentInsets
        realGroup.interItemSpacing = interItemSpacing
        return realGroup
    }
    
}

class CollectionVGroup: CollectionBase, CollectionGroup {
    
    let layoutSize: NSCollectionLayoutSize
    let subitems: [CollectionItem]
    var interItemSpacing: NSCollectionLayoutSpacing?
    
    init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        @CollectionBuilder subitemsBuilder: () -> [CollectionBase]
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        let items = subitemsBuilder()
        let subitems = items.compactMap { item in
            item as? CollectionItem
        }
        self.subitems = subitems
    }
    
    var realValue: NSCollectionLayoutGroup {
        let realGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: layoutSize,
            subitems: subitems.map({ $0.realValue })
        )
        realGroup.contentInsets = contentInsets
        realGroup.interItemSpacing = interItemSpacing
        return realGroup
    }
}

class CollectionSection: CollectionBase {
    
    let items: [CollectionBase]
    var interGroupSpacing: CGFloat = 0
    var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none
    
    init(
        @CollectionBuilder itemsBuilder: () -> [CollectionBase]
    ) {
        self.items = itemsBuilder()
    }
    
    var realValue: NSCollectionLayoutSection {
        let group = items.first { item in
            item is CollectionGroup
        }
        let boundaryItems = items.compactMap { item in
            item as? CollectionBoundary
        }
        let decorationItems = items.compactMap { item in
            item as? CollectionBackground
        }
        guard let group = group as? CollectionGroup else { fatalError("section 中必须定义 group") }
        let realSection: NSCollectionLayoutSection = .init(group: group.realValue)
        realSection.boundarySupplementaryItems = boundaryItems.map({ $0.realValue })
        realSection.decorationItems = decorationItems.map({ $0.realValue })
        realSection.contentInsets = contentInsets
        realSection.interGroupSpacing = interGroupSpacing
        realSection.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        return realSection
    }
    
}

class CollectionBoundary: CollectionBase {
    
    let layoutSize: NSCollectionLayoutSize
    let kind: String
    let alignment: NSRectAlignment
    var pinToVisibleBounds: Bool = false
    
    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(80),
        kind: String,
        alignment: NSRectAlignment
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.kind = kind
        self.alignment = alignment
    }
    
    var realValue: NSCollectionLayoutBoundarySupplementaryItem {
        let realBoundary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: kind,
            alignment: alignment
        )
        realBoundary.contentInsets = contentInsets
        realBoundary.pinToVisibleBounds = pinToVisibleBounds
        return realBoundary
    }
    
}

class CollectionBackground: CollectionBase {
    
    let kind: String
    init(
        kind: String
    ) {
        self.kind = kind
    }
    
    var realValue: NSCollectionLayoutDecorationItem {
        /// DecorationView （section背景）通过 UICollectionViewLayout 进行注册
        /// Each type of decoration item must have a unique element kind
        /// 例如: Section1BackGroundView 和 Section2BackGroundView 要注册为两个不同的 kind，并把 kind 当作 identifier 使用
        let realDecoration = NSCollectionLayoutDecorationItem.background(
            elementKind: kind
        )
        realDecoration.contentInsets = contentInsets
        return realDecoration
    }
    
}

// MARK: - support

@resultBuilder
struct CollectionBuilder {
    
    typealias Expression = CollectionBase
    typealias Component = [CollectionBase]
    
    static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    
    static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    
    static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    
    static func buildEither(first component: Component) -> Component {
        component
    }
    
    static func buildEither(second component: Component) -> Component {
        component
    }
    
    static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
    
}
