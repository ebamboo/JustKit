//
//  Created by 姚旭 on 2021/12/17.
//

import UIKit

public class TestFlowLayout: UICollectionViewFlowLayout {
    
    var itemSizeReader: ((UICollectionView) -> CGSize) = { _ in .init(width: 60, height: 60) }
    
    var minScale: CGFloat = 0.8
    
}

public extension TestFlowLayout {
    
    // 使用 itemSizeReader 设置 itemSize
    override func prepare() {
        super.prepare()
        if let collectionView {
            itemSize = itemSizeReader(collectionView)
        }
    }
    
    // 用于实现中心元素放大，两侧元素缩小
    // 注释该方法则没有放大缩小效果
    //
    //               ◄───────┐     ┌──────────►
    //  gradient scaling     │     │        gradient scaling
    //  minScale -- 1.0  │   │  │  │   │    minScale -- 1.0
    //                   │◄──┴─►│◄─┴──►│
    // ┌─────────────────┼──────┼──────┼─────────────────┐
    // │┌─────┐┌─────┐┌──┼──┐┌──┼──┐┌──┼──┐┌─────┐┌─────┐│
    // ││     ││     ││  │  ││  │  ││  │  ││     ││     ││
    // ││     ││     ││  │  ││  │  ││  │  ││     ││     ││
    // ││     ││     ││  │  ││  │  ││  │  ││     ││     ││
    // │└─────┘└─────┘└──┼──┘└──┼──┘└──┼──┘└─────┘└─────┘│
    // └─────────────────┼──────┼──────┼─────────────────┘
    //    ◄──────────────┤      │      ├───────────────►
    //       minScale    │      │      │       minScale
    //                      center line
    //                       no scaling
    //
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesList = super.layoutAttributesForElements(in: rect),
              !attributesList.isEmpty else { return nil }
        
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
    
    // 用于实现滑动结束时元素居中
    // 注释该方法则无居中效果
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
      
        // 1. 获取 collectionView 实例
        guard let collectionView = collectionView else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }
        
        // 2. 计算可见区域
        // 注意：这里使用 proposedContentOffset 作为起始点
        let visibleRect = CGRect(
            origin: proposedContentOffset,
            size: collectionView.bounds.size
        )
        
        // 3. 获取该区域内的所有布局属性
        guard let layoutAttributes = super.layoutAttributesForElements(in: visibleRect),
              !layoutAttributes.isEmpty else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }
        
        // 4. 根据滑动方向分情况处理
        if scrollDirection == .horizontal {
            
            // 水平布局：中心点在 x 轴上
            let horizontalCenter = proposedContentOffset.x + collectionView.bounds.width / 2
            
            // 5. 定义距离中心点最近的元素
            var nearestAttributes = layoutAttributes.first!
            
            // 6. 遍历所有属性，获取距离中心点最近元素
            for attributes in layoutAttributes {
                let distance = abs(attributes.center.x - horizontalCenter)
                let nearestDistance = abs(nearestAttributes.center.x - horizontalCenter)
                if distance < nearestDistance {
                    nearestAttributes = attributes
                }
            }
            
            // 7. 根据获取到的最近的元素，计算最终目标偏移量
            let offsetAdjustment = nearestAttributes.center.x - horizontalCenter
            return .init(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
            
        } else {
            
            // 垂直布局：中心点在 y 轴上
            let verticalCenter = proposedContentOffset.y + collectionView.bounds.height / 2
            
            // 5. 定义距离中心点最近的元素
            var nearestAttributes = layoutAttributes.first!
            
            // 6. 遍历所有属性，获取距离中心点最近元素
            for attributes in layoutAttributes {
                let distance = abs(attributes.center.y - verticalCenter)
                let nearestDistance = abs(nearestAttributes.center.y - verticalCenter)
                if distance < nearestDistance {
                    nearestAttributes = attributes
                }
            }
            
            // 7. 根据获取到的最近的元素，计算最终目标偏移量
            let offsetAdjustment = nearestAttributes.center.y - verticalCenter
            return .init(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
            
        }
        
    }
    
    // bounds 变化时，是否刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
}
