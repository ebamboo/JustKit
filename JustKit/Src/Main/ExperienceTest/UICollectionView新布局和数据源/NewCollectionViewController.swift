//
//  Created by 姚旭 on 2025/8/19.
//

import UIKit

class NewCollectionViewController: UIViewController {

    // MARK: ui
    
    // collection view
    lazy var collctionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.backgroundColor = .systemTeal
        view.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "TestCollectionViewCell")
        view.register(
                    SectionHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "SectionHeaderView"
                )
        view.register(BadegView.self, forSupplementaryViewOfKind: "BadegView", withReuseIdentifier: "BadegView")
        return view
    }()
    
    // 布局信息
    lazy var collectionLayout = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            switch sectionIndex {
            case 0: // 水平滑动，每列2个元素
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(210))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 0, leading: 30, bottom: 0, trailing: 30)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
                return section
            case 1: // 垂直滑动，每行2个元素
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(64) // 使用估计高度
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
            case 2:
                let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20), heightDimension: .absolute(20))
                let badge = NSCollectionLayoutSupplementaryItem(
                    layoutSize: badgeSize, elementKind: "BadegView",
                    containerAnchor: NSCollectionLayoutAnchor(edges: [.top, .trailing], absoluteOffset: .init(x: 0, y: 0)),
                    itemAnchor: NSCollectionLayoutAnchor(edges: [.bottom, .leading], absoluteOffset: .init(x: -10, y: 10))
                )
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333), heightDimension: .fractionalWidth(0.333))
                let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                
                let headerSize = NSCollectionLayoutSize(
                 widthDimension: .fractionalWidth(1.0),
                 heightDimension: .estimated(60) // 使用估计高度
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                 layoutSize: headerSize,
                 elementKind: UICollectionView.elementKindSectionHeader,
                 alignment: .top
                )
                header.pinToVisibleBounds = true // 吸附设置开启
                section.boundarySupplementaryItems = [header]
                
                return section
            case 3:
                let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20), heightDimension: .absolute(20))
                let badge = NSCollectionLayoutSupplementaryItem(
                    layoutSize: badgeSize, elementKind: "BadegView",
                    containerAnchor: NSCollectionLayoutAnchor(edges: [.top, .trailing], absoluteOffset: .init(x: 0, y: 0)),
                    itemAnchor: NSCollectionLayoutAnchor(edges: [.bottom, .leading], absoluteOffset: .init(x: -10, y: 10))
                )
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333), heightDimension: .fractionalWidth(0.333))
                let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
                    elementKind: "section-background")
                sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                section.decorationItems = [sectionBackgroundDecoration]
                
                return section
            default:
                return nil
            }
        }
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "section-background")
        return layout
    }()
    
    // 数据源
    lazy var collectionDataSource = {
        let dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collctionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as! TestCollectionViewCell
            cell.nameLabel.text = itemIdentifier
            return cell
        }
        dataSource.supplementaryViewProvider = { collctionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case  UICollectionView.elementKindSectionHeader:
                let header = collctionView.dequeueReusableSupplementaryView(
                               ofKind: kind,
                               withReuseIdentifier: "SectionHeaderView",
                               for: indexPath) as! SectionHeaderView
                header.configure(title: "Section \(indexPath.section)")
                return header
            case "BadegView":
                let badgeView = collctionView.dequeueReusableSupplementaryView(ofKind: "BadegView",
                                                                               withReuseIdentifier: "BadegView",
                                                                               for: indexPath) as! BadegView
                return badgeView
            default:
                return nil
            }
        }
        return dataSource
    }()
    
    // MARK: life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collctionView)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0, 1, 2, 3])
        snapshot.appendItems((0...20).map({"0:\($0)"}), toSection: 0)
        snapshot.appendItems((0...6).map({"1:\($0)"}), toSection: 1)
        snapshot.appendItems((0...4).map({"2:\($0)"}), toSection: 2)
        snapshot.appendItems((0...16).map({"3:\($0)"}), toSection: 3)
        collectionDataSource.apply(snapshot)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collctionView.frame = view.bounds
    }

}


class TestCollectionViewCell: UICollectionViewCell {
    
    lazy var nameLabel = {
        let label = UILabel()
        label.textColor = .red
        label.backgroundColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        addSubview(label)
        return label
        
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = bounds
    }
}


class BadegView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .red
        layer.cornerRadius = 10
    }
    
}

class SectionHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 添加标题标签
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        backgroundColor = .gray.withAlphaComponent(0.8)
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
}

class SectionBackgroundDecorationView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
    }
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        // 根据 section 不同设置不同的样式
        if layoutAttributes.indexPath.section == 0 {
            backgroundColor = UIColor.brown.withAlphaComponent(0.5)
        } else {
            backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
}
