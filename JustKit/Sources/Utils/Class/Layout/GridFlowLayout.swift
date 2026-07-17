//
//  Created by 姚旭 on 2021/12/17.
//

import UIKit

/// 支持通过闭包动态计算 `itemSize` 的 UICollectionViewFlowLayout。
///
/// 通过 `itemSizeProvider` 闭包根据 `UICollectionView` 的尺寸动态返回 `itemSize`，
/// 无需实现 `UICollectionViewDelegateFlowLayout` 代理方法，
/// 配合 `sectionInset`、`minimumInteritemSpacing` 等属性即可快速搭建网格布局。
///
/// ```swift
/// let layout = GridFlowLayout()
/// layout.minimumInteritemSpacing = 10
/// layout.minimumLineSpacing = 10
/// layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
/// layout.itemSizeProvider = { collectionView in
///     let columns: CGFloat = 3
///     let spacing: CGFloat = 10
///     let inset: CGFloat = 10
///     let width = (collectionView.bounds.width - inset * 2 - spacing * (columns - 1)) / columns
///     return CGSize(width: width, height: width)
/// }
/// let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
/// ```
///
/// - Note: `itemSizeProvider` 在每次布局刷新时调用，可自动适配屏幕旋转、分屏等尺寸变化。
public class GridFlowLayout: UICollectionViewFlowLayout {

    public var itemSizeProvider: ((UICollectionView) -> CGSize)?
    
    public override func prepare() {
        super.prepare()
        if let itemSizeProvider, let collectionView {
            itemSize = itemSizeProvider(collectionView)
        }
    }
    
}
