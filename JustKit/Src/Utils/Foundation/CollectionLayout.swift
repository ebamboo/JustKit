//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

///
/// DecorationView （section背景）通过 UICollectionViewLayout 进行注册
///
/// SupplementaryView（角标、section头部、section尾部）通过 UICollectionView 进行注册
///

// MARK: - base

protocol CollectionElement {
    func setup(_ block: (inout Self) -> Void) -> Self
}
extension CollectionElement{
    func setup(_ block: (inout Self) -> Void) -> Self {
        var copy = self;  block(&copy); return copy
    }
}

protocol CollectionGroupSubitem: CollectionElement {
    associatedtype RealValue: NSCollectionLayoutItem
    var realValue: RealValue { get }
}

// MARK: - components

struct CollectionItem: CollectionGroupSubitem {
    
    let layoutSize: NSCollectionLayoutSize
    let badges: [CollectionBadge]
    
    var contentInsets: NSDirectionalEdgeInsets = .zero
    
    init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.badges = []
    }
    
    init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        @CollectionElementBuilder<CollectionBadge> badges: () -> [CollectionBadge]
    ) {
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.badges = badges()
    }
    
    var realValue: NSCollectionLayoutItem {
        let realItem = NSCollectionLayoutItem(
            layoutSize: layoutSize,
            supplementaryItems: badges.map({ $0.realValue })
        )
        realItem.contentInsets = contentInsets
        return realItem
    }
    
}

struct CollectionGroup: CollectionGroupSubitem {
    
    enum Axis {
        case horizontal
        case vertical
    }
    
    let axis: Axis
    let layoutSize: NSCollectionLayoutSize
    let subitems: [any CollectionGroupSubitem]
    
    var contentInsets: NSDirectionalEdgeInsets = .zero
    var interItemSpacing: NSCollectionLayoutSpacing?
    
    init(
        axis: Axis = .horizontal,
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        @CollectionGroupSubitemBuilder subitems: () -> [any CollectionGroupSubitem]
    ) {
        self.axis = axis
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.subitems = subitems()
    }
    
    var realValue: NSCollectionLayoutGroup {
        let realGroup: NSCollectionLayoutGroup
        switch axis {
        case .horizontal:
            realGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: layoutSize,
                subitems: subitems.map({ $0.realValue })
            )
        case .vertical:
            realGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: layoutSize,
                subitems: subitems.map({ $0.realValue })
            )
        }
        realGroup.contentInsets = contentInsets
        realGroup.interItemSpacing = interItemSpacing
        return realGroup
    }
    
}

struct CollectionSection: CollectionElement {
    
    let groups: [CollectionGroup]
    let boundarys: [CollectionBoundary]
    let backgrounds: [CollectionBackground]
    
    var contentInsets: NSDirectionalEdgeInsets = .zero
    var interGroupSpacing: CGFloat = 0
    /// 正交方向滚动行为；须设置该属性以使 section 可正交方向滚动
    var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none
    
    init(
        @CollectionElementBuilder<CollectionGroup> groups: () -> [CollectionGroup]
    ) {
        self.groups = groups()
        self.boundarys = []
        self.backgrounds = []
    }
    
    init(
        @CollectionElementBuilder<CollectionGroup> groups: () -> [CollectionGroup],
        @CollectionElementBuilder<CollectionBoundary> boundarys: () -> [CollectionBoundary]
    ) {
        self.groups = groups()
        self.boundarys = boundarys()
        self.backgrounds = []
    }
    
    init(
        @CollectionElementBuilder<CollectionGroup> groups: () -> [CollectionGroup],
        @CollectionElementBuilder<CollectionBackground> backgrounds: () -> [CollectionBackground]
    ) {
        self.groups = groups()
        self.boundarys = []
        self.backgrounds = backgrounds()
    }
    
    init(
        @CollectionElementBuilder<CollectionGroup> groups: () -> [CollectionGroup],
        @CollectionElementBuilder<CollectionBoundary> boundarys: () -> [CollectionBoundary],
        @CollectionElementBuilder<CollectionBackground> backgrounds: () -> [CollectionBackground]
    ) {
        self.groups = groups()
        self.boundarys = boundarys()
        self.backgrounds = backgrounds()
    }
    
    var realValue: NSCollectionLayoutSection {
        guard let group = groups.first else { fatalError("section 中必须定义 group") }
        let realSection: NSCollectionLayoutSection = .init(group: group.realValue)
        realSection.boundarySupplementaryItems = boundarys.map({ $0.realValue })
        realSection.decorationItems = backgrounds.map({ $0.realValue })
        realSection.contentInsets = contentInsets
        realSection.interGroupSpacing = interGroupSpacing
        realSection.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        return realSection
    }
    
}

struct CollectionConfiguration: CollectionElement {
    
    let scrollDirection: UICollectionView.ScrollDirection
    let boundarys: [CollectionBoundary]
    
    var interSectionSpacing: CGFloat = 0
    
    init(
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        @CollectionElementBuilder<CollectionBoundary> boundarys: () -> [CollectionBoundary]
    ) {
        self.scrollDirection = scrollDirection
        self.boundarys = boundarys()
    }

    var realValue: UICollectionViewCompositionalLayoutConfiguration {
        let realConfig = UICollectionViewCompositionalLayoutConfiguration()
        realConfig.scrollDirection = scrollDirection
        realConfig.boundarySupplementaryItems = boundarys.map({ $0.realValue })
        realConfig.interSectionSpacing = interSectionSpacing
        return realConfig
    }
    
}

struct CollectionBadge: CollectionElement {
    
    enum Offset {
        case absolute(CGPoint)
        case fractional(CGPoint)
    }
    
    let layoutSize: NSCollectionLayoutSize
    let kind: String
    let alignment: NSDirectionalRectEdge
    let offset: Offset // 对齐之后，进行偏移; 只会影响 badge 位置，不会影响 cell 布局；
    
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
    
    var realValue: NSCollectionLayoutSupplementaryItem {
        let containerAnchor: NSCollectionLayoutAnchor = {
            switch offset {
            case .absolute(let point):
                return .init(edges: alignment, absoluteOffset: point)
            case .fractional(let point):
                return .init(edges: alignment, fractionalOffset: point)
            }
        }()
        let realBadge = NSCollectionLayoutSupplementaryItem(
            layoutSize: layoutSize,
            elementKind: kind,
            containerAnchor: containerAnchor
        )
        realBadge.contentInsets = contentInsets
        realBadge.zIndex = zIndex
        return realBadge
    }
    
}

struct CollectionBoundary: CollectionElement {
    
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
    
    var realValue: NSCollectionLayoutBoundarySupplementaryItem {
        let realBoundary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSize,
            elementKind: kind,
            alignment: alignment,
            absoluteOffset: offset
        )
        realBoundary.contentInsets = contentInsets
        realBoundary.zIndex = zIndex
        realBoundary.pinToVisibleBounds = pinToVisibleBounds
        return realBoundary
    }
    
}

struct CollectionBackground: CollectionElement {
    
    let kind: String
    
    var contentInsets: NSDirectionalEdgeInsets = .zero
    var zIndex: Int = 0
    
    init(
        kind: String
    ) {
        self.kind = kind
    }
    
    var realValue: NSCollectionLayoutDecorationItem {
        let realDecoration = NSCollectionLayoutDecorationItem.background(
            elementKind: kind
        )
        realDecoration.contentInsets = contentInsets
        realDecoration.zIndex = zIndex
        return realDecoration
    }
    
}

// MARK: - support

@resultBuilder
struct CollectionElementBuilder<Expression: CollectionElement> {
    
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

@resultBuilder
struct CollectionGroupSubitemBuilder {
    
    typealias Expression = any CollectionGroupSubitem
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
