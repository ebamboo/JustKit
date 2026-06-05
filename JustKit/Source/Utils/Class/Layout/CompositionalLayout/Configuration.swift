//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

extension CompositionalLayout {
    
    struct CollectionConfiguration: Element {
        
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
}
