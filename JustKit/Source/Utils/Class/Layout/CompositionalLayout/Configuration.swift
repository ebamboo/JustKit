//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
    /// 整个 CompositionalLayout 的全局配置。
    ///
    /// 控制 Collection 级别的行为：
    /// - `scrollDirection`：主滚动方向，默认 `.vertical`。
    /// - `interSectionSpacing`：相邻 Section 之间的间距。
    /// - `boundaries`：全局 Header/Footer，始终固定在 Collection 的首尾，不随单个 Section 滚动。
    ///
    /// 与 Section 内的 `BoundarySupplementary` 的区别：
    /// Section 内的 BoundarySupplementary 属于特定 Section，跟随该 Section 出现；
    /// Configuration 中的 BoundarySupplementary 属于整个 Collection，在所有 Section 之外。
    public struct Configuration: Element {
        
        public let scrollDirection: UICollectionView.ScrollDirection
        public let boundaries: [BoundarySupplementary]
        
        public var interSectionSpacing: CGFloat = 0
        
        public init(
            scrollDirection: UICollectionView.ScrollDirection = .vertical
        ) {
            self.scrollDirection = scrollDirection
            self.boundaries = []
        }
        
        public init(
            scrollDirection: UICollectionView.ScrollDirection = .vertical,
            @ElementBuilder<BoundarySupplementary> boundaries: () -> [BoundarySupplementary]
        ) {
            self.scrollDirection = scrollDirection
            self.boundaries = boundaries()
        }

        public var value: UICollectionViewCompositionalLayoutConfiguration {
            let result = UICollectionViewCompositionalLayoutConfiguration()
            result.scrollDirection = scrollDirection
            result.boundarySupplementaryItems = boundaries.map({ $0.value })
            result.interSectionSpacing = interSectionSpacing
            return result
        }
        
    }
    
}
