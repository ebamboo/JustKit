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
            let layout = createCollectionLayout()
            layout.register(
                ConvenienceCollectionViewTestSectionBackView.self,
                forDecorationViewOfKind: "ConvenienceCollectionViewTestSectionBackView"
            )
            collectionView.collectionViewLayout = layout
            
            collectionView.register(
                ConvenienceCollectionViewTestCell.self,
                forCellWithReuseIdentifier: "ConvenienceCollectionViewTestCell"
            )
            collectionView.register(
                ConvenienceCollectionViewTestBadegView.self,
                forSupplementaryViewOfKind: "badge-1",
                withReuseIdentifier: "ConvenienceCollectionViewTestBadegView")
            collectionView.register(
                ConvenienceCollectionViewTestBadegView.self,
                forSupplementaryViewOfKind: "badge-2",
                withReuseIdentifier: "ConvenienceCollectionViewTestBadegView")
            collectionView.register(
                ConvenienceCollectionViewTestSectionHeaderView.self,
                forSupplementaryViewOfKind: "section-header",
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView"
            )
            collectionView.register(
                ConvenienceCollectionViewTestSectionFooterView.self,
                forSupplementaryViewOfKind: "section-footer",
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionFooterView"
            )
            collectionView.dataSource = self
        }
    }
    
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
    
}

// MARK: - collection layout

extension NSCollectionLayoutSwiftUITestViewControllerViewController {
    
    func createCollectionLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout.custom { [weak self] sectionIndex, _ in
            guard let self, !self.testData.isEmpty else { return nil }
            guard self.testData.count > sectionIndex else { return nil }
            let section = self.testData[sectionIndex]
            switch section {
            case .banner: return self.bannerSection
            case .hot: return self.hotSection
            case .shop: return self.shopSection
            }
        }
    }
    
    var bannerSection: CollectionSection {
        CollectionSection {
            CollectionGroup(axis: .vertical, width: .absolute(100), height: .absolute(210)) {
                
                CollectionItem(width: .fractionalWidth(1), height: .fractionalHeight(0.5)) {
                    CollectionBadge(
                        width: .absolute(20),
                        height: .absolute(20),
                        kind: "badge-1",
                        alignment: [.top, .trailing],
                        offset: .fractional(.init(x: -0.5, y: 0))
                    ).setup { badge in
                        badge.zIndex = 7
                    }
                    CollectionBadge(
                        width: .absolute(20),
                        height: .absolute(20),
                        kind: "badge-2",
                        alignment: [.top, .trailing],
                        offset: .fractional(.init(x: 0, y: 0))
                    ).setup { badge in
                        badge.zIndex = 6
                    }
                }
                
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
            CollectionGroup(width: .fractionalWidth(1), height: .estimated(200)) {
                
                for w in [0.08, 0.12, 0.18] {
                    CollectionItem(width: .fractionalWidth(w), height: .absolute(160))
                }
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            }
        } boundarys: {
            if needHotHeadder {
                CollectionBoundary(kind: "section-header", alignment: .top)
                    .setup { header in
                        header.pinToVisibleBounds = true
                    }
            }
            if needHotFooter {
                CollectionBoundary(kind: "section-footer", alignment: .bottom)
            }
        } backgrounds: {
            
        }
        .setup { section in
            section.interGroupSpacing = 10
        }
    }
    
    var shopSection: CollectionSection {
        CollectionSection {
            CollectionGroup(width: .fractionalWidth(1), height: .estimated(200)) {
                
                CollectionItem(width: .fractionalWidth(0.5), height: .fractionalWidth(0.5))
                
            }
            .setup { group in
                group.interItemSpacing = .fixed(10)
            } 
        } backgrounds: {
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

extension NSCollectionLayoutSwiftUITestViewControllerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        testData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch testData[section] {
        case .banner:
            testBanners.count
        case .hot:
            testhots.count
        case .shop:
            testshops.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConvenienceCollectionViewTestCell", for: indexPath) as! ConvenienceCollectionViewTestCell
        cell.nameLabel.text = "\(indexPath.item+1)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch (kind, testData[indexPath.section]) {
        case ("badge-1", .banner):
            let badge = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ConvenienceCollectionViewTestBadegView",
                for: indexPath
            ) as! ConvenienceCollectionViewTestBadegView
            badge.backgroundColor = .brown
            return badge
        case ("badge-2", .banner):
            let badge = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ConvenienceCollectionViewTestBadegView",
                for: indexPath
            ) as! ConvenienceCollectionViewTestBadegView
            badge.backgroundColor = .red
            return badge
        case ("section-header", .hot):
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView",
                for: indexPath
            ) as! ConvenienceCollectionViewTestSectionHeaderView
            header.configure(title: "Hot Section Header")
            return header
        case ("section-footer", .hot):
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionFooterView",
                for: indexPath
            ) as! ConvenienceCollectionViewTestSectionFooterView
            footer.configure(title: "Hot Section Header:\nsubtitle1\nsubtitle2\nsubtitle3")
            return footer
        default:
            return UICollectionReusableView()
        }
    }
    
}
