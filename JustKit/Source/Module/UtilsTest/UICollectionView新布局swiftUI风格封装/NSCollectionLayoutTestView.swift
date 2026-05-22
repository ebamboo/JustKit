//
//  Created by 姚旭 on 2025/11/28.
//

import UIKit

class ConvenienceCollectionViewTestCell: UICollectionViewCell {
    
    lazy var nameLabel = {
        let label = UILabel()
        label.textColor = .red
        label.backgroundColor = .systemGroupedBackground
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(nameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = bounds
    }
    
}

class ConvenienceCollectionViewTestBadegView: UICollectionReusableView {
    
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

class ConvenienceCollectionViewTestSectionHeaderView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.numberOfLines = 0
        label.backgroundColor = .brown
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        backgroundColor = .gray.withAlphaComponent(0.8)
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
}

class ConvenienceCollectionViewTestSectionFooterView: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.numberOfLines = 0
        label.backgroundColor = .brown
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        backgroundColor = .gray.withAlphaComponent(0.8)
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
}

class ConvenienceCollectionViewTestSectionBackView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        backgroundColor = .brown
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        backgroundColor = .brown
    }
    
//    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.apply(layoutAttributes)
//        // 根据 section 不同设置不同的样式
//        if layoutAttributes.indexPath.section == 0 {
//            backgroundColor = UIColor.brown.withAlphaComponent(0.5)
//        } else {
//            backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        }
//    }
    
}
