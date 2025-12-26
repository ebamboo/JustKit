//
//  Created by 姚旭 on 2022/9/24.
//

import UIKit

public extension CollectionViewTagLayout {
    
    var lineSpacing: CGFloat {
        get {
            _lineSpacing
        }
        set {
            _lineSpacing = newValue
        }
    }
    var interitemSpacing: CGFloat {
        get {
            _interitemSpacing
        }
        set {
            _interitemSpacing = newValue
        }
    }
    var itemHeight: CGFloat {
        get {
            _itemHeight
        }
        set {
            _itemHeight = newValue
        }
    }
    func itemWidthReader(_ reader: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> CGFloat) {
        _itemWidthReader = reader
    }
    
}

public class CollectionViewTagLayout: UICollectionViewLayout {

    private var _lineSpacing = 10.0
    private var _interitemSpacing = 10.0
    private var _itemHeight = 20.0
    private var _itemWidthReader = { (collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat in 60.0 }

    private var _contentHeight = 0.0
    private var _layoutAttributesForItems = [UICollectionViewLayoutAttributes]()
        
}

public extension CollectionViewTagLayout {
    
    override func prepare() {
        super.prepare()
        
        // 清空记录数据
        _contentHeight = 0.0
        _layoutAttributesForItems = []
        
        // 空
        guard let collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        guard numberOfItems > 0 else { return }
        
        // 首项
        let firstIndexPath = IndexPath(item: 0, section: 0)
        let firstAttributes = UICollectionViewLayoutAttributes(forCellWith: firstIndexPath)
        firstAttributes.frame = .init(x: 0, y: 0, width: _itemWidthReader(collectionView, firstIndexPath), height: _itemHeight)
        _contentHeight = _itemHeight
        _layoutAttributesForItems.append(firstAttributes)
        
        // n + 1 项
        guard numberOfItems > 1 else { return }
        (1..<numberOfItems).forEach { i in
            let indexPath = IndexPath(item: i, section: 0)
            let itemWidth = _itemWidthReader(collectionView, indexPath)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let precedingAttributes = _layoutAttributesForItems[i-1]
            // 如果本行尾部可以追加
            if precedingAttributes.frame.maxX + _interitemSpacing + itemWidth <= collectionView.bounds.size.width {
                attributes.frame = .init(
                    x: precedingAttributes.frame.maxX + _interitemSpacing,
                    y: precedingAttributes.frame.minY,
                    width: itemWidth,
                    height: _itemHeight
                )
                _layoutAttributesForItems.append(attributes)
            }
            // 否则新开辟一行追加
            else {
                attributes.frame = CGRect(
                    x: 0,
                    y: precedingAttributes.frame.maxY + _lineSpacing,
                    width: itemWidth,
                    height: _itemHeight
                )
                _contentHeight += (_lineSpacing + _itemHeight)
                _layoutAttributesForItems.append(attributes)
            }
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        _layoutAttributesForItems.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < _layoutAttributesForItems.count else { return nil }
        return _layoutAttributesForItems[indexPath.item]
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView else { return .zero }
        return .init(width: collectionView.bounds.width, height: _contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView else { return false }
        return newBounds.width != collectionView.bounds.width
    }
    
}
