//
//  NSCollectionLayoutSwiftUITestViewControllerViewController.swift
//  JustKit
//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

class NSCollectionLayoutSwiftUITestViewControllerViewController: UIViewController {
    
    // MARK: - ui
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            
            collectionView.collectionViewLayout = collectionLayout
            
            collectionView.register(
                ConvenienceCollectionViewTestCell.self,
                forCellWithReuseIdentifier: "ConvenienceCollectionViewTestCell"
            )
            collectionView.register(
                ConvenienceCollectionViewTestBadegView.self,
                forSupplementaryViewOfKind: Self.BannerSctionBadgeKind,
                withReuseIdentifier: "ConvenienceCollectionViewTestBadegView"
            )
            collectionView.register(
                ConvenienceCollectionViewTestSectionHeaderView.self,
                forSupplementaryViewOfKind: Self.HotSctionHeaderKind,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView"
            )
            collectionView.register(
                ConvenienceCollectionViewTestSectionFooterView.self,
                forSupplementaryViewOfKind: Self.HotSctionFooterKind,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionFooterView"
            )
            
        }
    }
    lazy var collectionLayout = layout
    lazy var collectionDataSource = dataSource
    
    // MARK: - test data
    
    lazy var testData: [HomeSection] = [
        HomeSection.banner, HomeSection.hot, HomeSection.shop
    ]
    
    lazy var testBanners: [HomeItem] = {
        (0...20).map { i in
            HomeItem.banner(BannerModel(id: i))
        }
    }()
    
    lazy var testhots: [HomeItem] = {
        (0...20).map { i in
            HomeItem.hot(HotModel(id: i))
        }
    }()
    
    lazy var testshops: [HomeItem] = {
        (0...20).map { i in
            HomeItem.shop(ShopModel(id: i))
        }
    }()
    
    // 通过数据控制是否显示相关的装饰视图，例如背景、头部、尾部
    // 根据实际的业务需求和数据，控制相关的开关
    var needBack = true
    var needHotHeadder = true
    var needHotFooter = true
    
    // MARK: - life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        snapshot.appendSections(testData)
        testData.forEach { section in
            let items: [HomeItem]
            switch section {
            case .banner:
                items = testBanners
            case .hot:
                items = testhots
            case .shop:
                items = testshops
            }
            snapshot.appendItems(items, toSection: section)
        }
        collectionDataSource.apply(snapshot)
        
    }

}

// MARK: - collection layout

extension NSCollectionLayoutSwiftUITestViewControllerViewController {
    
    static let BannerSctionBadgeKind = "BannerSction.Badge"
    static let HotSctionHeaderKind = "HotSction.Header"
    static let HotSctionFooterKind = "HotSction.Footer"
    static let ShopSctionBackKind = "ShopSction.Back"
    
    var layout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self, !self.testData.isEmpty else { return nil }
            guard self.testData.count > sectionIndex else { return nil }
            let section = self.testData[sectionIndex]
            switch section {
            case .banner: return self.bannerSection
            case .hot: return self.hotSection
            case .shop: return self.shopSection
            }
        }
        layout.register(
            ConvenienceCollectionViewTestSectionBackView.self,
            forDecorationViewOfKind: Self.ShopSctionBackKind
        )
        return layout
    }
    
    var bannerSection: NSCollectionLayoutSection {
        NSCollectionLayoutSection {
            
            NSCollectionLayoutGroup.vertical(
                layoutSize: .init(widthDimension: .absolute(100), heightDimension: .absolute(210))
            ) {
                
                NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
                ) {
                    NSCollectionLayoutSupplementaryItem(
                        layoutSize: .init(widthDimension: .absolute(20), heightDimension: .absolute(20)),
                        elementKind: Self.BannerSctionBadgeKind,
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
    
    var hotSection: NSCollectionLayoutSection {
        NSCollectionLayoutSection {
            
            if needHotHeadder {
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)),
                    elementKind: Self.HotSctionHeaderKind,
                    alignment: .top
                )
                .setup { header in
                    header.pinToVisibleBounds = true // 可以吸附 header
                }
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
            
            if needHotFooter {
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60)),
                    elementKind: Self.HotSctionFooterKind,
                    alignment: .bottom
                )
            }
            
        }
        .setup { section in
            section.interGroupSpacing = 10
        }
    }
    
    var shopSection: NSCollectionLayoutSection {
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
            
            if needBack {
                NSCollectionLayoutDecorationItem.background(elementKind: Self.ShopSctionBackKind)
                    .setup { back in
                        // 通过注释和反注释以下代码观察 insets 效果
                        back.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
                    }
            }
            
        }
        .setup { section in
            section.contentInsets = .init(top: 40, leading: 40, bottom: 40, trailing: 40)
            section.interGroupSpacing = 10
        }
    }
    
}

// MARK: -  collection data source

extension NSCollectionLayoutSwiftUITestViewControllerViewController {
    
    var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem> {
        let dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConvenienceCollectionViewTestCell", for: indexPath) as! ConvenienceCollectionViewTestCell
            cell.nameLabel.text = "\(indexPath.item+1)"
            return cell
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case Self.BannerSctionBadgeKind:
                let badge = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ConvenienceCollectionViewTestBadegView",
                    for: indexPath
                ) as! ConvenienceCollectionViewTestBadegView
                return badge
            case Self.HotSctionHeaderKind:
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView",
                    for: indexPath
                ) as! ConvenienceCollectionViewTestSectionHeaderView
                header.configure(title: "Hot Section Header")
                return header
            case Self.HotSctionFooterKind:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ConvenienceCollectionViewTestSectionFooterView",
                    for: indexPath
                ) as! ConvenienceCollectionViewTestSectionFooterView
                footer.configure(title: "Hot Section Header:\nfsjfksjflslfkjlsfjklsdkfjd;afkds;fjkdf;asfdksjfkdsfdsjfkalsdfjdslf;asdfjdskfdsjdksdsfkkasasf")
                return footer
            default:
                return nil
            }
        }
        return dataSource
    }
    
}
