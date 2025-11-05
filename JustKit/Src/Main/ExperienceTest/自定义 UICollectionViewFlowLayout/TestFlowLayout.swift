//
//  Created by 姚旭 on 2021/12/17.
//

import UIKit

class TestFlowLayout: UICollectionViewFlowLayout {

    var itemSizeReader: ((UICollectionView) -> CGSize)!
    
    /// 初始化或其他以下动态布局操作
    override func prepare() {
        super.prepare()
        /// 每次刷新布局都会调整 itemSize 大小
        itemSize = itemSizeReader(collectionView!)
    }
    
    /// 布局变化时，是否刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    /// 对每个 cell 对应的布局 attributes 做出说明或者修改
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesList = super.layoutAttributesForElements(in: rect),
              attributesList.isEmpty == false
        else { return [] }
        
        // 渐变缩放区域
        let areaDistance = itemSize.width + minimumLineSpacing
        // 水平居中线
        let centerLineX = collectionView!.contentOffset.x + collectionView!.bounds.width/2
        attributesList.forEach { attributes in
            let distance = abs(attributes.center.x - centerLineX)
            if distance > areaDistance {
                attributes.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } else {
                attributes.transform = CGAffineTransform(scaleX: 1-distance*0.2/areaDistance, y: 1-distance*0.2/areaDistance)
            }
        }
        return attributesList
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
      
        ///
        /// 以预想的proposed结束位置进行处理计算
        ///
        let proposedRect = CGRect(x: proposedContentOffset.x,
                                  y: proposedContentOffset.y,
                                  width: collectionView!.bounds.width,
                                  height: collectionView!.bounds.height)
        guard let proposedAttributesList = super.layoutAttributesForElements(in: proposedRect),
              proposedAttributesList.isEmpty == false else { return proposedContentOffset }
        let proposedCenterLineX = proposedContentOffset.x + collectionView!.bounds.width/2
        // 获取绝对值最小的偏移量
        let delta = proposedAttributesList.reduce(into: 10000.0) { prefect, attributes in
            if abs(attributes.center.x - proposedCenterLineX) < abs(prefect) {
                prefect = attributes.center.x - proposedCenterLineX
            }
        }
        return CGPoint(x: proposedContentOffset.x+delta, y: proposedContentOffset.y)
        
    }
    
}
