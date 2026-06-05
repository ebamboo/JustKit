//
//  Created by 姚旭 on 2025/12/25.
//

import UIKit

public final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    
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
