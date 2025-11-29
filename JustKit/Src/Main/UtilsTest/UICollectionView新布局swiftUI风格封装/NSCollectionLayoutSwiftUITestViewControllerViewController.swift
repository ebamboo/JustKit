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
                ConvenienceCollectionViewTestSectionHeaderView.self,
                forSupplementaryViewOfKind: .sectionHeader,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView"
            )
            collectionView.register(
                ConvenienceCollectionViewTestSectionFooterView.self,
                forSupplementaryViewOfKind: .sectionFooter,
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
    
    var layout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout.custom { [weak self] sectionIndex, _ in
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
            forDecorationViewOfKind: "ConvenienceCollectionViewTestSectionBackView"
        )
        return layout
    }
    
    var bannerSection: CollectionSection {
        CollectionSection {
            
            CollectionVGroup(width: .absolute(100), height: .absolute(210)) {
                
                CollectionItem(width: .fractionalWidth(1), height: .fractionalHeight(0.5))
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
            
        }
        .setup { section in
            section.interGroupSpacing = 10
            section.orthogonalScrollingBehavior = .continuous
        }
    }
    
    var hotSection: CollectionSection {
        CollectionSection {
            
            if needHotHeadder {
                CollectionBoundary(kind: .sectionHeader, alignment: .top)
                    .setup { header in
                        header.pinToVisibleBounds = true
                    }
            }
            
            CollectionHGroup(width: .fractionalWidth(1), height: .estimated(200)) {
                
                CollectionItem(width: .fractionalWidth(0.08), height: .absolute(160))
                
                CollectionItem(width: .fractionalWidth(0.12), height: .absolute(160))
                
                CollectionItem(width: .fractionalWidth(0.18), height: .absolute(160))
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
            
            if needHotFooter {
                CollectionBoundary(kind: .sectionFooter, alignment: .bottom)
            }
            
        }
        .setup { section in
            section.interGroupSpacing = 10
        }
    }
    
    var shopSection: CollectionSection {
        CollectionSection {
            
            CollectionHGroup(width: .fractionalWidth(1), height: .estimated(200)) {
                
                CollectionItem(width: .fractionalWidth(0.5), height: .fractionalWidth(0.5))
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
            
            if needBack {
                CollectionBackground(kind: "ConvenienceCollectionViewTestSectionBackView")
                    .setup { back in
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
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self else { return nil }
            switch (kind, self.testData[indexPath.section]) {
            case (.sectionHeader, .hot):
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView",
                    for: indexPath
                ) as! ConvenienceCollectionViewTestSectionHeaderView
                header.configure(title: "Hot Section Header")
                return header
            case (.sectionFooter, .hot):
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
