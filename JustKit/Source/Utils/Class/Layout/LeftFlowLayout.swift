//
//  Created by 姚旭 on 2025/12/25.
//

import UIKit

/// 左对齐的 UICollectionViewFlowLayout。
///
/// UICollectionViewFlowLayout 默认将行内剩余空间均分到元素间距中，
/// 使首尾元素分别贴近行的两端。
/// 本布局将其修正为左对齐排列，元素间距固定为 `minimumInteritemSpacing`，
/// 剩余空间保留在行尾。
/// 适用于标签（Tag）、筛选条件等不定宽度元素的自动换行布局。
///
/// ```swift
/// let layout = LeftFlowLayout()
/// layout.minimumInteritemSpacing = 8
/// layout.minimumLineSpacing = 8
/// layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
/// let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
/// ```
///
/// - Note: `minimumInteritemSpacing` 在此布局中表现为精确的行内间距，而非最小值。
/// - Important: 仅支持垂直滚动方向（`scrollDirection = .vertical`）。
public final class LeftFlowLayout: UICollectionViewFlowLayout {
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let superAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        let attributes = superAttributes.copy() as! UICollectionViewLayoutAttributes
        
        guard indexPath.item > 0 else {
            attributes.frame.origin.x = sectionInset.left
            return attributes
        }
        
        let precedingIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        guard let superPrecedingAttributes = super.layoutAttributesForItem(at: precedingIndexPath) else { return attributes }
        
        // 判断换行时使用 super 的布局信息，可利用系统缓存
        // 如果当前元素的 minY 大于前一个元素的 maxY，说明不在同一行
        if superAttributes.frame.minY > superPrecedingAttributes.frame.maxY {
            attributes.frame.origin.x = sectionInset.left
        }
        // 同一行时使用修正后的前项布局信息作为参考
        else {
            guard let precedingAttributes = self.layoutAttributesForItem(at: precedingIndexPath) else { return attributes }
            attributes.frame.origin.x = precedingAttributes.frame.maxX + minimumInteritemSpacing
        }
        
        return attributes
        
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributesList = super.layoutAttributesForElements(in: rect) else { return nil }
        let attributesList = superAttributesList.map { $0.copy() as! UICollectionViewLayoutAttributes }
        attributesList.forEach { attributes in
            // 只处理 cell 布局
            if attributes.representedElementCategory == .cell,
               let frame = self.layoutAttributesForItem(at: attributes.indexPath)?.frame {
                attributes.frame = frame
            }
        }
        return attributesList
    }
    
}
