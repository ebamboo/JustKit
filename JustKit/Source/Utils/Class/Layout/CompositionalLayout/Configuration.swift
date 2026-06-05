//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
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