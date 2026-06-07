//
//  Created by 姚旭 on 2021/11/26.
//

import UIKit

class ImageGridView: UICollectionView {
    
    struct Configuration {
        var contentInsets: UIEdgeInsets = .zero
        var spacing: CGFloat = 8
        var itemSizeProvider: ((_ gridView: ImageGridView) -> CGSize) = { _ in .zero }
        var addIcon: UIImage?
        var deleteIcon: UIImage?
        var imageLoader: ((_ imageView: UIImageView, _ url: URL) -> Void)?
        var maximumImageCount: Int = 9
    }

    var configuration = Configuration() {
        didSet { reloadData() }
    }

    init(frame: CGRect, configuration: Configuration = .init()) {
        self.configuration = configuration
        super.init(frame: frame, collectionViewLayout: ImageGridLayout())
        dataSource = self
        delegate = self
        register(ImageGridCell.self, forCellWithReuseIdentifier: "ImageGridCell")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        collectionViewLayout = ImageGridLayout()
        dataSource = self
        delegate = self
        register(ImageGridCell.self, forCellWithReuseIdentifier: "ImageGridCell")
    }
    
    
    enum Mode {
        case browse
        case edit
    }

    var mode: Mode = .browse {
        didSet { reloadData() }
    }
    
    
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
    

    var didTapAddButton: (() -> Void)?
    var didTapImage: ((Int, ImageSource) -> Void)?
    var didDeleteImage: ((Int, ImageSource) -> Void)?

    // MARK: - Autosize

    override var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }

    // MARK: - Helpers

    fileprivate var showsAddButton: Bool {
        mode == .edit && images.count < configuration.maximumImageCount
    }
}

// MARK: - DataSource & Delegate

extension ImageGridView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showsAddButton ? images.count + 1 : images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageGridCell", for: indexPath) as! ImageGridCell
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
            cell.didTapDeleteButton = { [weak self] in
                guard let self else { return }
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

class ImageGridCell: UICollectionViewCell {
    // MARK: - 应该是什么命名呢
    var didTapDeleteButton: (() -> Void)?
    // MARK: - Components
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
    // MARK: - Override
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func deleteTapped() {
        didTapDeleteButton?()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        deleteButton.isHidden = true
        didTapDeleteButton = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        deleteButton.frame = CGRect(x: contentView.bounds.width - 30, y: 0, width: 30, height: 30)
    }
}

class ImageGridLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let gridView = collectionView as? ImageGridView else { return }
        sectionInset = gridView.configuration.contentInsets
        minimumInteritemSpacing = gridView.configuration.spacing
        minimumLineSpacing = gridView.configuration.spacing
        itemSize = gridView.configuration.itemSizeProvider(gridView)
    }
}
