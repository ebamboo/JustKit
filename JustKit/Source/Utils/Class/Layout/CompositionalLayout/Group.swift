//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
    /// Item 的容器，负责将多个子元素（Item 或嵌套 Group）按指定方向排列。
    ///
    /// `axis` 控制排列方向：`.horizontal` 水平排列，`.vertical` 垂直排列。
    /// Group 自身也遵循 `ItemConvertible`，因此可以作为外层 Group 的子元素实现嵌套布局。
    ///
    /// 每个 Section 有且仅有一个 Group，Section 通过重复该 Group 来填充其内容区域。
    /// Group 内部的子元素排列规则由 `subitems` 数组中各元素的尺寸比例共同决定。
    public struct Group: ItemConvertible {
        
        public enum Axis {
            case horizontal
            case vertical
        }
        
        public let axis: Axis
        public let layoutSize: NSCollectionLayoutSize
        public let subitems: [any ItemConvertible]
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        public var interItemSpacing: NSCollectionLayoutSpacing?
        
        public init(
            axis: Axis = .horizontal,
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            @ItemConvertibleBuilder subitems: () -> [any ItemConvertible]
        ) {
            self.axis = axis
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.subitems = subitems()
        }
        
        public var value: NSCollectionLayoutGroup {
            let result: NSCollectionLayoutGroup
            switch axis {
            case .horizontal:
                result = NSCollectionLayoutGroup.horizontal(
                    layoutSize: layoutSize,
                    subitems: subitems.map({ $0.value })
                )
            case .vertical:
                result = NSCollectionLayoutGroup.vertical(
                    layoutSize: layoutSize,
                    subitems: subitems.map({ $0.value })
                )
            }
            result.contentInsets = contentInsets
            result.interItemSpacing = interItemSpacing
            return result
        }
        
    }
    
}