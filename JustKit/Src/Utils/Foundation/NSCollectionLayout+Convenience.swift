//
//  Created by 姚旭 on 2025/11/28.
//

import UIKit

///
/// DecorationView （section背景）通过 UICollectionViewLayout 进行注册
///
/// SupplementaryView（角标、section头部、section尾部）通过 UICollectionView 进行注册
///

/*
 UICollectionViewLayout 相关注册方法
open func register(_ viewClass: AnyClass?, forDecorationViewOfKind elementKind: String)
open func register(_ nib: UINib?, forDecorationViewOfKind elementKind: String)
*/

/*
 UICollectionView 相关注册方法
open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String)
open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String)
open func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String)
open func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String)
*/

// MARK: - setup

protocol NSCollectionLayoutItemSetup {
    func setup(_ block: (Self) -> Void) -> Self
}
extension NSCollectionLayoutItemSetup {
    func setup(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}
extension NSCollectionLayoutItem: NSCollectionLayoutItemSetup {}
extension NSCollectionLayoutSection: NSCollectionLayoutItemSetup {}

// MARK: - convenience

extension NSCollectionLayoutItem {
    
    convenience init(
        layoutSize: NSCollectionLayoutSize,
        @CollectionLayoutItemBuilder supplementaryItemsBuilder: () -> [NSCollectionLayoutItem]
    ) {
        let items = supplementaryItemsBuilder()
        let supplementaryItems = items.compactMap { item in
            item as? NSCollectionLayoutSupplementaryItem
        }
        self.init(layoutSize: layoutSize, supplementaryItems: supplementaryItems)
    }
    
}

extension NSCollectionLayoutGroup {
    
    /// horizontal 表示 subitems 在 group 内水平排列
    static func horizontal(
        layoutSize: NSCollectionLayoutSize,
        @CollectionLayoutItemBuilder subitemsBuilder: () -> [NSCollectionLayoutItem]
    ) -> Self {
        Self.horizontal(layoutSize: layoutSize, subitems: subitemsBuilder())
    }
    
    /// vertical 表示 subitems 在 group 内垂直排列
    /// 如果需要 section 水平方向滑动，需要使用 vertical  group，
    /// 并且设置 NSCollectionLayoutSection 的 orthogonalScrollingBehavior
    static func vertical(
        layoutSize: NSCollectionLayoutSize,
        @CollectionLayoutItemBuilder subitemsBuilder: () -> [NSCollectionLayoutItem]
    ) -> Self {
        Self.vertical(layoutSize: layoutSize, subitems: subitemsBuilder())
    }
    
}

extension NSCollectionLayoutSection {
    
    convenience init(
        @CollectionLayoutItemBuilder subitemsBuilder: () -> [NSCollectionLayoutItem]
    ) {
        let items = subitemsBuilder()
        let group = items.first { item in
            item.isKind(of: NSCollectionLayoutGroup.self)
        }
        let boundarySupplementaryItems = items.compactMap { item in
            item as? NSCollectionLayoutBoundarySupplementaryItem
        }
        let decorationItems = items.compactMap { item in
            item as? NSCollectionLayoutDecorationItem
        }
        self.init(group: group as! NSCollectionLayoutGroup)
        self.boundarySupplementaryItems = boundarySupplementaryItems
        self.decorationItems = decorationItems
    }
    
}

// MARK: - support

@resultBuilder
struct CollectionLayoutItemBuilder {
    
    typealias Expression = NSCollectionLayoutItem
    typealias Component = [NSCollectionLayoutItem]
    
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
