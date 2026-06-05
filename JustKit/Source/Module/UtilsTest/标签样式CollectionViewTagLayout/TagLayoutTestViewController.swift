//
//  Created by 姚旭 on 2022/9/24.
//

import UIKit

class TagLayoutTestViewController: UIViewController, UICollectionViewDataSource {

    private let tags = [
        "Swift", "iOS", "UIKit", "SwiftUI", "Objective-C",
        "Xcode", "CocoaPods", "SPM", "自动布局",
        "左对齐标签", "标签样式", "CollectionView",
        "FlowLayout", "自适应宽度", "Tag",
        "短", "0这是一个比较长的标签0", "中等标签",
        "开发工具", "UI组件", "布局", "测试",
        "LeftFlowLayout", "自定义布局", "间距固定",
        "响应式", "动态内容", "A", "数据驱动",
        "Swift", "iOS", "UIKit", "SwiftUI", "Objective-C",
        "Xcode", "CocoaPods", "SPM", "自动布局",
        "左对齐标签", "标签样式", "CollectionView",
        "FlowLayout", "自适应宽度", "Tag",
        "短", "0这是一个比较长的标签0", "中等标签",
        "开发工具", "UI组件", "布局", "测试",
        "LeftFlowLayout", "自定义布局", "间距固定",
        "响应式", "动态内容", "A", "数据驱动",
    ]
    
    private let tagColors: [(bg: UIColor, text: UIColor)] = [
        (.systemBlue,   .white),
        (.systemGreen,  .white),
        (.systemOrange, .white),
        (.systemPink,   .white),
        (.systemPurple, .white),
        (.systemTeal,   .white),
    ]
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = LeftFlowLayout()
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            collectionView.collectionViewLayout = layout
            collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "标签布局"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        let color = tagColors[indexPath.item % tagColors.count]
        cell.configure(text: tags[indexPath.item], bgColor: color.bg, textColor: color.text)
        return cell
    }

}

// MARK: - TagCell

private class TagCell: UICollectionViewCell {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true

        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 160)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String, bgColor: UIColor, textColor: UIColor) {
        label.text = text
        label.textColor = textColor
        contentView.backgroundColor = bgColor
    }

}
