//
//  Created by 姚旭 on 2025/12/25.
//

import UIKit

public class CollectionViewWrapLayout: UICollectionViewFlowLayout {
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let originalLayoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        let layoutAttributes = originalLayoutAttributes.copy() as! UICollectionViewLayoutAttributes
        
        guard indexPath.item > 0 else {
            layoutAttributes.frame.origin.x = sectionInset.left
            return layoutAttributes
        }
        let precedingIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
        guard let originalPrecedingLayoutAttributes = super.layoutAttributesForItem(at: precedingIndexPath) else { return layoutAttributes }
        
        // 如果当前元素的 minY 大于前一个元素的maxY，说明当前元素和前一个元素不在同一行
        // 当前元素作为所在行第一个元素
        if layoutAttributes.frame.minY > originalPrecedingLayoutAttributes.frame.maxY {
            layoutAttributes.frame.origin.x = sectionInset.left
        }
        // 否则说明和前一个元素在同一行，则在其后布局
        // 在同一行时使用真正的 preceding 布局信息作为布局参考
        // 在此之前使用 originalPrecedingLayoutAttributes 可利用系统的缓存
        else {
            guard let precedingLayoutAttributes = self.layoutAttributesForItem(at: precedingIndexPath) else { return layoutAttributes }
            layoutAttributes.frame.origin.x = precedingLayoutAttributes.frame.maxX + minimumInteritemSpacing
        }
        
        // 返回经过重新布局的 layoutAttributes
        return layoutAttributes
        
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalLayoutAttributesList = super.layoutAttributesForElements(in: rect) else { return nil }
        let layoutAttributesList = originalLayoutAttributesList.map({ $0.copy() as! UICollectionViewLayoutAttributes })
        layoutAttributesList.forEach { layoutAttributes in
            // 只处理 cell 布局
            if layoutAttributes.representedElementCategory == .cell,
               let frame = self.layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                layoutAttributes.frame = frame
            }
        }
        return layoutAttributesList
    }
    
}
