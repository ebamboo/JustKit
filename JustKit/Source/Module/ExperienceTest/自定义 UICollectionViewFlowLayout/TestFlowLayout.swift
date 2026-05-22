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
            if scrollDirection == .horizontal {
                let inset = collectionView.bounds.width / 2 - itemSize.width / 2
                collectionView.contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
            } else {
                let inset = collectionView.bounds.height / 2 - itemSize.height / 2
                collectionView.contentInset = .init(top: inset, left: 0, bottom: inset, right: 0)
            }
        }
    }
    
    // 用于实现中心元素不缩放，两侧元素缩小
    // 注释该方法则没有放大缩小效果
    // 以水平方向滚动的 collection view 为例进行如下说明:
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
        guard let collectionView = collectionView,
              let originalAttributes = super.layoutAttributesForElements(in: rect),
              !originalAttributes.isEmpty else { return nil }
        
        // 计算视图中心点坐标
        let viewCenter = CGPoint(
            x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
            y: collectionView.contentOffset.y + collectionView.bounds.height / 2
        )
        
        // 计算渐变缩放区域范围
        let gradientRange: CGFloat
        if scrollDirection == .horizontal {
            gradientRange = itemSize.width + minimumLineSpacing
        } else {
            gradientRange = itemSize.height + minimumLineSpacing
        }
        
        // 计算缩放差值（从1.0到minScale）
        let scaleDifference = 1.0 - minScale
        
        // 遍历并更新每个元素的缩放变换
        originalAttributes.forEach { attr in
            // 计算元素中心到视图中心的距离
            let distance: CGFloat
            if scrollDirection == .horizontal {
                distance = abs(attr.center.x - viewCenter.x)
            } else {
                distance = abs(attr.center.y - viewCenter.y)
            }
            
            // 根据距离计算缩放比例
            let calculatedScale: CGFloat
            if distance >= gradientRange {
                // 超出渐变范围，使用最小缩放
                calculatedScale = minScale
            } else {
                // 在渐变范围内，线性插值计算缩放（1.0 -> minScale）
                let progress = distance / gradientRange
                calculatedScale = 1.0 - scaleDifference * progress
            }
            
            // 应用缩放变换
            attr.transform = CGAffineTransform(scaleX: calculatedScale, y: calculatedScale)
        }
        
        return originalAttributes
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
