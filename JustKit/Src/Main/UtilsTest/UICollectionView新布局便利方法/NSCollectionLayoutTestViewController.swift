//
//  Created by 姚旭 on 2025/11/28.
//

import UIKit

class NSCollectionLayoutTestViewController: UIViewController {

    // MARK: - ui
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
                guard let self, !self.testData.isEmpty else { return nil }
                guard testData.count > sectionIndex else { return nil }
                let section = testData[sectionIndex]
                switch section {
                case .banner: return HomeSection.bannerSection
                case .hot: return HomeSection.hotSection
                case .shop: return HomeSection.shopSection
                }
            }
            layout.register(
                ConvenienceCollectionViewTestSectionBackView.self,
                forDecorationViewOfKind: HomeSection.ShopSctionBackKind
            )
            
            collectionView.collectionViewLayout = layout
            collectionView.backgroundColor = .systemTeal
            
            collectionView.register(
                ConvenienceCollectionViewTestCell.self,
                forCellWithReuseIdentifier: "ConvenienceCollectionViewTestCell"
            )
            collectionView.register(
                ConvenienceCollectionViewTestBadegView.self,
                forSupplementaryViewOfKind: HomeSection.BannerSctionBadgeKind,
                withReuseIdentifier: "ConvenienceCollectionViewTestBadegView"
            )
            collectionView.register(
                ConvenienceCollectionViewTestSectionHeaderView.self,
                forSupplementaryViewOfKind: HomeSection.HotSctionHeaderKind,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView"
            )
            collectionView.register(
                ConvenienceCollectionViewTestSectionFooterView.self,
                forSupplementaryViewOfKind: HomeSection.HotSctionFooterKind,
                withReuseIdentifier: "ConvenienceCollectionViewTestSectionFooterView"
            )
        }
    }
    
    // 数据源
    lazy var collectionDataSource = {
        let dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConvenienceCollectionViewTestCell", for: indexPath) as! ConvenienceCollectionViewTestCell
            cell.nameLabel.text = "\(indexPath.item+1)"
            return cell
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case HomeSection.BannerSctionBadgeKind:
                let badge = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ConvenienceCollectionViewTestBadegView",
                    for: indexPath
                ) as! ConvenienceCollectionViewTestBadegView
                return badge
            case HomeSection.HotSctionHeaderKind:
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ConvenienceCollectionViewTestSectionHeaderView",
                    for: indexPath
                ) as! ConvenienceCollectionViewTestSectionHeaderView
                header.configure(title: "Hot Section Header")
                return header
            case HomeSection.HotSctionFooterKind:
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
    }()
    
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
