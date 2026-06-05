//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - BoundarySupplementary

extension CompositionalLayout {
    
    /// Section 或 Collection 级别的边界附属视图，常用于 SectionHeader、SectionFooter。
    ///
    /// 通过 `alignment` 指定位置：`.top` 为 Header，`.bottom` 为 Footer。
    /// 放在 `Section` 中时作用于单个 Section；放在 `Configuration` 中时作用于整个 Collection（全局 Header/Footer）。
    ///
    /// **视图注册：**
    /// 使用 `UICollectionView.register(_:forSupplementaryViewOfKind:withReuseIdentifier:)` 注册，
    /// `kind` 须与布局中传入的 `kind` 一致；
    /// 在 `dataSource.supplementaryViewProvider` 或
    /// `collectionView(_:viewForSupplementaryElementOfKind:at:)` 中提供视图。
    ///
    /// **注意事项：**
    /// - `pinToVisibleBounds = true` 时视图会吸附在可视区域边缘（类似 sticky header），此时 `zIndex` 无效。
    /// - `offset` 会影响 Section 的布局空间，与 `Supplementary` 的 offset 仅影响位置不同。
    public struct BoundarySupplementary: Element {
        
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
    
}

// MARK: - Decoration

extension CompositionalLayout {
    
    /// Section 级别的装饰视图，常用于为整个 Section 添加背景色、圆角背景、阴影等装饰效果。
    ///
    /// Decoration 不承载数据，不参与 DataSource 流程，仅作为纯视觉装饰层。
    /// 其尺寸自动匹配所属 Section 的内容区域，无需手动指定 layoutSize。
    ///
    /// **视图注册：**
    /// 与 Supplementary 和 BoundarySupplementary 不同，Decoration 不通过 `UICollectionView` 注册，
    /// 而是通过 `UICollectionViewCompositionalLayout.register(_:forDecorationViewOfKind:)` 注册。
    /// 注册的视图须继承 `UICollectionReusableView`。
    ///
    /// **注意事项：**
    /// - 不通过 DataSource 提供视图，因此视图的配置（如背景色）需在自定义 `UICollectionReusableView` 子类中完成。
    /// - `contentInsets` 可用于让背景相对 Section 内容区域内缩或外扩。
    /// - `zIndex` 默认为 0，通常位于 Cell 和 Supplementary 之下；若需覆盖在上层，需手动调高。
    public struct Decoration: Element {
        
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
    
}

// MARK: - Section

extension CompositionalLayout {
    
    public struct Section: Element {
        
        public let group: Group
        public let boundaries: [BoundarySupplementary]
        public let decorations: [Decoration]
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        public var interGroupSpacing: CGFloat = 0
        /// 正交方向滚动行为；须设置该属性以使 section 可正交方向滚动
        public var orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none
        
        public init(
            group: () -> Group
        ) {
            self.group = group()
            self.boundaries = []
            self.decorations = []
        }
        
        public init(
            group: () -> Group,
            @ElementBuilder<BoundarySupplementary> boundaries: () -> [BoundarySupplementary]
        ) {
            self.group = group()
            self.boundaries = boundaries()
            self.decorations = []
        }
        
        public init(
            group: () -> Group,
            @ElementBuilder<Decoration> decorations: () -> [Decoration]
        ) {
            self.group = group()
            self.boundaries = []
            self.decorations = decorations()
        }
        
        public init(
            group: () -> Group,
            @ElementBuilder<BoundarySupplementary> boundaries: () -> [BoundarySupplementary],
            @ElementBuilder<Decoration> decorations: () -> [Decoration]
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
    
}