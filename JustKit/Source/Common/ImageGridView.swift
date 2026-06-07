//
//  Created by 姚旭 on 2021/11/26.
//

import UIKit

// MARK: - ImageGridView

/// 项目级图片网格组件，迁移到其他项目时需做少量源码适配。
///
/// 基于 UICollectionView 封装，支持浏览和编辑两种模式。
/// 编辑模式下显示添加按钮和删除按钮，图片来源支持本地 UIImage 和远程 URL。
/// 自身不可滚动，高度随内容自适应，适合嵌入 ScrollView 或表单使用。
///
/// ```
/// var config = ImageGridView.Configuration()
/// config.spacing = 10
/// config.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
/// config.addIcon = UIImage(named: "add")
/// config.deleteIcon = UIImage(named: "delete")
/// config.imageSizeProvider = { gridView in
///     let columns: CGFloat = 4
///     let insets = gridView.configuration.contentInsets
///     let totalSpacing = insets.left + insets.right + gridView.configuration.spacing * (columns - 1)
///     let side = floor((gridView.bounds.width - totalSpacing) / columns)
///     return CGSize(width: side, height: side)
/// }
///
/// let gridView = ImageGridView(frame: .zero, configuration: config)
/// gridView.mode = .edit
/// gridView.setImages([.image(UIImage(named: "photo")!)])
///
/// gridView.didTapAddButton = { /* 选择图片 */ }
/// gridView.didTapImage = { index, source in /* 预览图片 */ }
/// gridView.didDeleteImage = { index, source in /* 处理删除 */ }
/// ```
class ImageGridView: UICollectionView {
    
    // MARK: Configuration
    
    struct Configuration {
        var contentInsets: UIEdgeInsets = .zero
        var spacing: CGFloat = 8
        var imageSizeProvider: ((_ gridView: ImageGridView) -> CGSize) = { _ in .init(width: 120, height: 120) }
        var addIcon: UIImage?
        var deleteIcon: UIImage?
        var imageLoader: ((_ imageView: UIImageView, _ url: URL) -> Void)?
        var maximumImageCount: Int = 9
    }

    var configuration = Configuration() {
        didSet { reloadData() }
    }
    
    // MARK: Mode
    
    enum Mode {
        case browse
        case edit
    }

    var mode: Mode = .browse {
        didSet { reloadData() }
    }
    
    // MARK: Images
    
    enum ImageSource {
        case image(UIImage)
        case url(URL)
    }

    private(set) var images: [ImageSource] = []

    func setImages(_ images: [ImageSource]) {
        guard images.count <= configuration.maximumImageCount else { return }
        self.images = images
        reloadData()
    }

    func appendImages(_ images: [ImageSource]) {
        guard self.images.count + images.count <= configuration.maximumImageCount else { return }
        self.images += images
        reloadData()
    }
    
    // MARK: Callbacks
    
    var didTapAddButton: (() -> Void)?
    var didTapImage: ((Int, ImageSource) -> Void)?
    var didDeleteImage: ((Int, ImageSource) -> Void)?

    // MARK: Override

    init(frame: CGRect, configuration: Configuration = .init()) {
        self.configuration = configuration
        super.init(frame: frame, collectionViewLayout: ImageGridLayout())
        isScrollEnabled = false
        dataSource = self
        delegate = self
        register(ImageGridCell.self, forCellWithReuseIdentifier: "ImageGridCell")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        collectionViewLayout = ImageGridLayout()
        isScrollEnabled = false
        dataSource = self
        delegate = self
        register(ImageGridCell.self, forCellWithReuseIdentifier: "ImageGridCell")
    }
    
    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }

    // MARK: Helpers

    private var showsAddButton: Bool {
        mode == .edit && images.count < configuration.maximumImageCount
    }
    
}

// MARK: - DataSource & Delegate

extension ImageGridView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showsAddButton ? images.count + 1 : images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ImageGridCell",
            for: indexPath
        ) as! ImageGridCell
        if showsAddButton && indexPath.item == images.count {
            cell.imageView.image = configuration.addIcon
            cell.deleteButton.isHidden = true
            cell.didTapDeleteButton = nil
        } else {
            switch images[indexPath.item] {
            case .image(let image):
                cell.imageView.image = image
            case .url(let url):
                configuration.imageLoader?(cell.imageView, url)
            }
            cell.deleteButton.isHidden = mode != .edit
            cell.deleteButton.setImage(configuration.deleteIcon, for: .normal)
            cell.didTapDeleteButton = { [weak self, weak cell] in
                guard let self,
                      let cell,
                      let indexPath = self.indexPath(for: cell) else { return }
                let removed = self.images.remove(at: indexPath.item)
                self.reloadData()
                self.didDeleteImage?(indexPath.item, removed)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if showsAddButton && indexPath.item == images.count {
            didTapAddButton?()
        } else {
            didTapImage?(indexPath.item, images[indexPath.item])
        }
    }
}

// MARK: - ImageGridCell

private class ImageGridCell: UICollectionViewCell {
    // MARK: Interface
    var didTapDeleteButton: (() -> Void)?
    // MARK: Components
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    lazy var deleteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return view
    }()
    // MARK: Override
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        deleteButton.frame = CGRect(
            x: contentView.bounds.size.width - 30,
            y: 0,
            width: 30,
            height: 30
        )
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        deleteButton.isHidden = true
        didTapDeleteButton = nil
    }
    // MARK: Actions
    @objc func deleteTapped() {
        didTapDeleteButton?()
    }
}

// MARK: - ImageGridLayout

private class ImageGridLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let gridView = collectionView as? ImageGridView else { return }
        sectionInset = gridView.configuration.contentInsets
        minimumInteritemSpacing = gridView.configuration.spacing
        minimumLineSpacing = gridView.configuration.spacing
        itemSize = gridView.configuration.imageSizeProvider(gridView)
    }
}
