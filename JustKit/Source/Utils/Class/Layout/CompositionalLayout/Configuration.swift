//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
    struct Configuration: Element {
        
        let scrollDirection: UICollectionView.ScrollDirection
        let boundaries: [BoundarySupplementary]
        
        var interSectionSpacing: CGFloat = 0
        
        init(
            scrollDirection: UICollectionView.ScrollDirection = .vertical,
            @ElementBuilder<BoundarySupplementary> boundaries: () -> [BoundarySupplementary]
        ) {
            self.scrollDirection = scrollDirection
            self.boundaries = boundaries()
        }

        var value: UICollectionViewCompositionalLayoutConfiguration {
            let result = UICollectionViewCompositionalLayoutConfiguration()
            result.scrollDirection = scrollDirection
            result.boundarySupplementaryItems = boundaries.map({ $0.value })
            result.interSectionSpacing = interSectionSpacing
            return result
        }
        
    }
}
