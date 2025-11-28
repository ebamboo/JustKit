//
//  Created by 姚旭 on 2025/11/28.
//

import UIKit

enum HomeSection {
    case banner
    case hot
    case shop
}

enum HomeItem: Hashable {
    case banner(BannerModel)
    case hot(HotModel)
    case shop(ShopModel)
}

struct BannerModel: Hashable {
    let id: Int
}

struct HotModel: Hashable {
    let id: Int
}

struct ShopModel: Hashable {
    let id: Int
}

extension HomeSection {
    
    static let BannerSctionBadgeKind = "BannerSction.Badge"
    static let HotSctionHeaderKind = "HotSction.Header"
    static let HotSctionFooterKind = "HotSction.Footer"
    static let ShopSctionBackKind = "ShopSction.Back"
    
    static var bannerSection: NSCollectionLayoutSection {
        NSCollectionLayoutSection {
            
            NSCollectionLayoutGroup.vertical(
                layoutSize: .init(widthDimension: .absolute(100), heightDimension: .absolute(210))
            ) {
                
                NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
                ) {
                    NSCollectionLayoutSupplementaryItem(
                        layoutSize: .init(widthDimension: .absolute(20), heightDimension: .absolute(20)),
                        elementKind: HomeSection.BannerSctionBadgeKind,
                        containerAnchor: .init(
                            edges: [.top, .trailing],
                            absoluteOffset: .init(x: 0, y: 0)
                        ),
                        itemAnchor: .init(
                            edges: [.bottom, .leading],
                            absoluteOffset: .init(x: -10, y: 10)
                        )
                    )
                }
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
            
        }
        .setup { section in
            section.interGroupSpacing = 10
            /// ！！！！！！！！！！！ 想要 section 内容水平滚动必须设置该属性 ！！！！！！！！！！！！
            section.orthogonalScrollingBehavior = .continuous
        }
    }
    
    static var hotSection: NSCollectionLayoutSection {
        NSCollectionLayoutSection {
            
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)),
                elementKind: HomeSection.HotSctionHeaderKind,
                alignment: .top
            )
            .setup { header in
                header.pinToVisibleBounds = true // 可以吸附 header
            }
            
            NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
            ) {
                
                NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(0.08), heightDimension: .absolute(160))
                )
                
                NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(0.12), heightDimension: .absolute(160))
                )
                
                NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(0.18), heightDimension: .absolute(160))
                )
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
            
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)),
                elementKind: HomeSection.HotSctionFooterKind,
                alignment: .bottom
            )
            
        }
        .setup { section in
            section.interGroupSpacing = 10
        }
    }
    
    static var shopSection: NSCollectionLayoutSection {
        NSCollectionLayoutSection {
            
            NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
            ) {
                
                NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
                )
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
            
            NSCollectionLayoutDecorationItem.background(elementKind: HomeSection.ShopSctionBackKind)
                .setup { back in
                    // 通过注释和反注释以下代码观察 insets 效果
                    back.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
                }
            
        }
        .setup { section in
            section.contentInsets = .init(top: 40, leading: 40, bottom: 40, trailing: 40)
            section.interGroupSpacing = 10
        }
    }
    
}
