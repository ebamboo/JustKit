//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

/// Item 的容器，负责将多个子元素（LayoutItem 或嵌套 LayoutGroup）按指定方向排列。
///
/// `axis` 控制排列方向：`.horizontal` 水平排列，`.vertical` 垂直排列。
/// LayoutGroup 自身也遵循 `LayoutItemConvertible`，因此可以作为外层 LayoutGroup 的子元素实现嵌套布局。
///
/// 每个 LayoutSection 有且仅有一个 LayoutGroup，LayoutSection 通过重复该 LayoutGroup 来填充其内容区域。
/// LayoutGroup 内部的子元素排列规则由 `subitems` 数组中各元素的尺寸比例共同决定。
public struct LayoutGroup: LayoutItemConvertible {
    
    public let axis: NSLayoutConstraint.Axis
    public let layoutSize: NSCollectionLayoutSize
    public let subitems: [any LayoutItemConvertible]
    
    public var contentInsets: NSDirectionalEdgeInsets = .zero
    public var interItemSpacing: NSCollectionLayoutSpacing?
    
    public init(
        axis: NSLayoutConstraint.Axis = .horizontal,
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        @LayoutItemConvertibleBuilder subitems: () -> [any LayoutItemConvertible]
    ) {
        self.axis = axis
        self.layoutSize = .init(widthDimension: width, heightDimension: height)
        self.subitems = subitems()
    }
    
    public var value: NSCollectionLayoutGroup {
        let result: NSCollectionLayoutGroup
        switch axis {
        case .vertical:
            result = NSCollectionLayoutGroup.vertical(
                layoutSize: layoutSize,
                subitems: subitems.map({ $0.value })
            )
        default:
            result = NSCollectionLayoutGroup.horizontal(
                layoutSize: layoutSize,
                subitems: subitems.map({ $0.value })
            )
        }
        result.contentInsets = contentInsets
        result.interItemSpacing = interItemSpacing
        return result
    }
    
}
