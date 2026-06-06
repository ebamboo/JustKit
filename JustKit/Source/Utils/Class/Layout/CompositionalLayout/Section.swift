//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - LayoutBoundary

/// Section 或 Collection 级别的边界附属视图，常用于 Header、Footer。
///
/// 通过 `alignment` 指定位置：`.top` 为 Header，`.bottom` 为 Footer。
/// 放在 `LayoutSection` 中时作用于单个 Section；放在 `LayoutConfiguration` 中时作用于整个 Collection（全局 Header/Footer）。
///
/// **视图注册：**
/// 使用 `UICollectionView.register(_:forSupplementaryViewOfKind:withReuseIdentifier:)` 注册，
/// `kind` 须与布局中传入的 `kind` 一致；
/// 在 `dataSource.supplementaryViewProvider` 或
/// `collectionView(_:viewForSupplementaryElementOfKind:at:)` 中提供视图。
///
/// **注意事项：**
/// - `pinToVisibleBounds = true` 时视图会吸附在可视区域边缘（类似 sticky header），此时 `zIndex` 无效。
/// - `offset` 会影响 Section 的布局空间，与 `LayoutSupplementary` 的 offset 仅影响位置不同。
public struct LayoutBoundary: LayoutElement {
    
    public let layoutSize: NSCollectionLayoutSize
    public let kind: String
    public let alignment: NSRectAlignment
    public let offset: CGPoint // 对齐之后，进行偏移; 可能会影响 section 布局，以达到不会遮盖其他 section 内容；
    
    public var contentInsets: NSDirectionalEdgeInsets = .zero
    public var zIndex: Int = 0 // pinToVisibleBounds 为 true 时，zIndex 无效
    public var pinToVisibleBounds: Bool = false // 是否吸附
    
    public init(
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
    
    public var value: NSCollectionLayoutBoundarySupplementaryItem {
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

// MARK: - LayoutDecoration

/// Section 级别的装饰视图，常用于为整个 Section 添加背景色、圆角背景、阴影等装饰效果。
///
/// LayoutDecoration 不承载数据，不参与 DataSource 流程，仅作为纯视觉装饰层。
/// 其尺寸自动匹配所属 Section 的内容区域，无需手动指定 layoutSize。
///
/// **视图注册：**
/// 与 LayoutSupplementary 和 LayoutBoundary 不同，LayoutDecoration 不通过 `UICollectionView` 注册，
/// 而是通过 `UICollectionViewCompositionalLayout.register(_:forDecorationViewOfKind:)` 注册。
/// 注册的视图须继承 `UICollectionReusableView`。
///
/// **注意事项：**
/// - 不通过 DataSource 提供视图，因此视图的配置（如背景色）需在自定义 `UICollectionReusableView` 子类中完成。
/// - `contentInsets` 可用于让背景相对 Section 内容区域内缩或外扩。
/// - `zIndex` 默认为 0，通常位于 Cell 和 LayoutSupplementary 之下；若需覆盖在上层，需手动调高。
public struct LayoutDecoration: LayoutElement {
    
    public let kind: String
    
    public var contentInsets: NSDirectionalEdgeInsets = .zero
    public var zIndex: Int = 0
    
    public init(
        kind: String
    ) {
        self.kind = kind
    }
    
    public var value: NSCollectionLayoutDecorationItem {
        let result = NSCollectionLayoutDecorationItem.background(
            elementKind: kind
        )
        result.contentInsets = contentInsets
        result.zIndex = zIndex
        return result
    }
    
}

// MARK: - LayoutSection

/// 核心分区单元，每个 Section 独立定义自己的布局规则。
///
/// 一个 LayoutSection 包含一个 `LayoutGroup`（定义 Cell 的排列方式），
/// 以及可选的 `LayoutBoundary`（Header/Footer）和 `LayoutDecoration`（背景装饰）。
///
/// 不同 Section 可以拥有完全不同的布局结构，这是 CompositionalLayout 区别于 FlowLayout 的核心能力。
/// 通过 `orthogonalScrollingBehavior` 可使单个 Section 支持正交方向（横向）滚动。
public struct LayoutSection: LayoutElement {
    
    public let group: LayoutGroup
    public let boundaries: [LayoutBoundary]
    public let decorations: [LayoutDecoration]
    
    public var contentInsets: NSDirectionalEdgeInsets = .zero
    public var interGroupSpacing: CGFloat = 0
    /// 正交方向滚动行为。须设置该属性以使 section 可正交方向滚动。
    public var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none
    
    public init(
        group: () -> LayoutGroup
    ) {
        self.group = group()
        self.boundaries = []
        self.decorations = []
    }
    
    public init(
        group: () -> LayoutGroup,
        @LayoutElementBuilder<LayoutBoundary> boundaries: () -> [LayoutBoundary]
    ) {
        self.group = group()
        self.boundaries = boundaries()
        self.decorations = []
    }
    
    public init(
        group: () -> LayoutGroup,
        @LayoutElementBuilder<LayoutDecoration> decorations: () -> [LayoutDecoration]
    ) {
        self.group = group()
        self.boundaries = []
        self.decorations = decorations()
    }
    
    public init(
        group: () -> LayoutGroup,
        @LayoutElementBuilder<LayoutBoundary> boundaries: () -> [LayoutBoundary],
        @LayoutElementBuilder<LayoutDecoration> decorations: () -> [LayoutDecoration]
    ) {
        self.group = group()
        self.boundaries = boundaries()
        self.decorations = decorations()
    }
    
    public var value: NSCollectionLayoutSection {
        let result: NSCollectionLayoutSection = .init(group: group.value)
        result.boundarySupplementaryItems = boundaries.map({ $0.value })
        result.decorationItems = decorations.map({ $0.value })
        result.contentInsets = contentInsets
        result.interGroupSpacing = interGroupSpacing
        result.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        return result
    }
    
}