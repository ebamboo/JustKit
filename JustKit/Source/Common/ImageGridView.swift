//
//  Created by 姚旭 on 2021/11/26.
//

import UIKit

class ImageGridView: UICollectionView {

    // MARK: - Configuration & Init

    struct Configuration {
        
        var contentInsets: UIEdgeInsets = .zero
        var spacing: CGFloat = 8
        var itemSizeProvider: ((_ bounds: CGRect) -> CGSize)?
        
        var maximumImageCount: Int = 9
        
        var addIcon: UIImage?
        var deleteIcon: UIImage?
        var imageLoader: ((_ imageView: UIImageView, _ url: URL) -> Void)?
        
    }

    var configuration = Configuration() {
        didSet { reloadData() }
    }

    init(frame: CGRect, configuration: Configuration = .init()) {
        self.configuration = configuration
        super.init(frame: frame, collectionViewLayout: GridLayout())
        dataSource = self
        delegate = self
        register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseID)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        collectionViewLayout = GridLayout()
        dataSource = self
        delegate = self
        register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseID)
    }

    // MARK: - Mode

    enum Mode {
        case browse
        case edit
    }

    var mode: Mode = .browse {
        didSet { reloadData() }
    }

    // MARK: - Items

    enum ImageSource {
        case image(UIImage)
        case url(URL)
    }

    private(set) var items: [ImageSource] = []

    func setItems(_ newItems: [ImageSource]) {
        guard newItems.count <= configuration.maximumImageCount else { return }
        items = newItems
        reloadData()
    }

    func appendItems(_ newItems: [ImageSource]) {
        guard items.count + newItems.count <= configuration.maximumImageCount else { return }
        items += newItems
        reloadData()
    }

    // MARK: - Callbacks

    var onAddTap: (() -> Void)?
    var onItemTap: ((_ index: Int) -> Void)?
    var onItemDelete: ((_ index: Int) -> Void)?

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
        mode == .edit && items.count < configuration.maximumImageCount
    }
}

// MARK: - DataSource & Delegate

extension ImageGridView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showsAddButton ? items.count + 1 : items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseID, for: indexPath) as! GridCell
        if showsAddButton && indexPath.item == items.count {
            cell.imageView.image = configuration.addIcon
            cell.deleteButton.isHidden = true
            cell.onDelete = nil
        } else {
            switch items[indexPath.item] {
            case .image(let image):
                cell.imageView.image = image
            case .url(let url):
                configuration.imageLoader?(cell.imageView, url)
            }
            cell.deleteButton.isHidden = mode != .edit
            cell.deleteButton.setImage(configuration.deleteIcon, for: .normal)
            cell.onDelete = { [weak self] in
                guard let self else { return }
                self.items.remove(at: indexPath.item)
                self.reloadData()
                self.onItemDelete?(indexPath.item)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if showsAddButton && indexPath.item == items.count {
            onAddTap?()
        } else {
            onItemTap?(indexPath.item)
        }
    }
}

// MARK: - GridCell

extension ImageGridView {

    fileprivate class GridCell: UICollectionViewCell {

        static let reuseID = "ImageGridView.GridCell"

        lazy var imageView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            contentView.insertSubview(view, at: 0)
            return view
        }()

        lazy var deleteButton: UIButton = {
            let view = UIButton(type: .custom)
            view.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            contentView.addSubview(view)
            return view
        }()

        var onDelete: (() -> Void)?

        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.image = nil
            deleteButton.isHidden = true
            onDelete = nil
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = contentView.bounds
            deleteButton.frame = CGRect(x: contentView.bounds.width - 30, y: 0, width: 30, height: 30)
        }

        @objc private func deleteTapped() {
            onDelete?()
        }
    }
}

// MARK: - GridLayout

extension ImageGridView {

    fileprivate class GridLayout: UICollectionViewFlowLayout {
        override func prepare() {
            super.prepare()
            guard let gridView = collectionView as? ImageGridView else { return }
            if let provider = gridView.configuration.itemSizeProvider {
                itemSize = provider(gridView.bounds)
            } else {
                let columns: CGFloat = 4
                let insets = gridView.configuration.contentInsets
                let totalSpacing = insets.left + insets.right + gridView.configuration.spacing * (columns - 1)
                let side = floor((gridView.bounds.width - totalSpacing) / columns)
                itemSize = CGSize(width: side, height: side)
            }
            sectionInset = gridView.configuration.contentInsets
            minimumInteritemSpacing = gridView.configuration.spacing
            minimumLineSpacing = gridView.configuration.spacing
        }
//        override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//            collectionView?.bounds.width != newBounds.width
//        }
    }
}
