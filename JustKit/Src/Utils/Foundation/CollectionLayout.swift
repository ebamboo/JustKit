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
        block(self); return self
    }
}

class CollectionBase: CollectionBaseSetup {
    var contentInsets: NSDirectionalEdgeInsets = .zero
}

typealias ElementKind = String
extension ElementKind {
    static let sectionHeader = UICollectionView.elementKindSectionHeader
    static let sectionFooter = UICollectionView.elementKindSectionFooter
}

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
        @CollectionBuilder<CollectionItem> subitems: () -> [CollectionItem]
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.subitems = subitems()
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
        @CollectionBuilder<CollectionItem> subitems: () -> [CollectionItem]
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.subitems = subitems()
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
    
    let group: CollectionGroup
    let header: [CollectionBoundary]
    let footer: [CollectionBoundary]
    let background: [CollectionBackground]
    
    var interGroupSpacing: CGFloat = 0
    /// 设置该属性才会使得 section 横向滑动
    var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none
    
    init(
        group: () -> CollectionGroup
    ) {
        self.group = group()
        self.header = []
        self.footer = []
        self.background = []
    }
    
    init(
        group: () -> CollectionGroup,
        @CollectionBuilder<CollectionBackground> background: () -> [CollectionBackground]
    ) {
        self.group = group()
        self.header = []
        self.footer = []
        self.background = background()
    }
    
    init(
        group: () -> CollectionGroup,
        @CollectionBuilder<CollectionBoundary> header: () -> [CollectionBoundary]
    ) {
        self.group = group()
        self.header = header()
        self.footer = []
        self.background = []
    }
    
    init(
        group: () -> CollectionGroup,
        @CollectionBuilder<CollectionBoundary> footer: () -> [CollectionBoundary]
    ) {
        self.group = group()
        self.header = []
        self.footer = footer()
        self.background = []
    }
    
    init(
        group: () -> CollectionGroup,
        @CollectionBuilder<CollectionBoundary> header: () -> [CollectionBoundary],
        @CollectionBuilder<CollectionBoundary> footer: () -> [CollectionBoundary]
    ) {
        self.group = group()
        self.header = header()
        self.footer = footer()
        self.background = []
    }
    
    init(
        group: () -> CollectionGroup,
        @CollectionBuilder<CollectionBoundary> header: () -> [CollectionBoundary],
        @CollectionBuilder<CollectionBoundary> footer: () -> [CollectionBoundary],
        @CollectionBuilder<CollectionBackground> background: () -> [CollectionBackground]
    ) {
        self.group = group()
        self.header = header()
        self.footer = footer()
        self.background = background()
    }
    
    var realValue: NSCollectionLayoutSection {
        let realSection: NSCollectionLayoutSection = .init(group: group.realValue)
        realSection.boundarySupplementaryItems = header.map({ $0.realValue }) + footer.map({ $0.realValue })
        realSection.decorationItems = background.map({ $0.realValue })
        realSection.contentInsets = contentInsets
        realSection.interGroupSpacing = interGroupSpacing
        realSection.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        return realSection
    }
    
}

/// 如果多个 section 的 header 通过不同的 UIView 实现，则为每一个 HeaderView 注册不同的 kind（一般用类名）
/// 这样其实可以通过 kind 就可以确定具体哪个 HeaderView 了
/// 如果所有的 section 使用同一个类型 UIView 实现，则只需为该 HeaderView 注册一次，且 kind 推荐为 .sectionHeader
///
/// 一个 BoundaryView 类型可以注册多次，但是 kind 不能相同，例如：
/// register(BoundaryView.self, forSupplementaryViewOfKind: .sectionHeader, withReuseIdentifier: "BoundaryView")
/// register(BoundaryView.self, forSupplementaryViewOfKind: .sectionFooter, withReuseIdentifier: "BoundaryView")
class CollectionBoundary: CollectionBase {
    
    let layoutSize: NSCollectionLayoutSize
    let kind: ElementKind
    let alignment: NSRectAlignment
    /// 是否吸附
    var pinToVisibleBounds: Bool = false
    
    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(80),
        kind: ElementKind,
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
        /// 一般以类名作为 kind
        let realDecoration = NSCollectionLayoutDecorationItem.background(
            elementKind: kind
        )
        realDecoration.contentInsets = contentInsets
        return realDecoration
    }
    
}

// MARK: - support

@resultBuilder
struct CollectionBuilder<Expression: CollectionBase> {
    
    typealias Component = [Expression]
    
    static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    
    static func buildBlock() -> Component {
        []
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
