//
//  Created by 姚旭 on 2022/7/3.
//

import UIKit

public extension UIImage {
    
    /// 旋转（可选镜像）生成新图片
    ///
    /// 以图片中心为锚点，**顺时针**旋转指定弧度
    /// 画布自动扩展为旋转后的外接矩形，空白区域透明
    /// 输出图像 scale 与原图一致，保留原图 `renderingMode`
    ///
    /// - Parameters:
    ///   - radians: **顺时针**旋转弧度（正值顺时针，负值逆时针）
    ///   - mirrored: 是否先水平镜像再旋转，默认 false
    /// - Returns: 变换后的新图片
    func rotated(by radians: CGFloat, mirrored: Bool = false) -> UIImage {
        guard size.width > 0, size.height > 0 else { return self }
        guard radians != 0 || mirrored else { return self }
        
        // 矩形旋转后的外接矩形公式：
        // 宽 = |w·cosθ| + |h·sinθ|
        // 高 = |w·sinθ| + |h·cosθ|
        let absSin = abs(sin(radians))
        let absCos = abs(cos(radians))
        let canvasSize = CGSize(
            width: size.width * absCos + size.height * absSin,
            height: size.width * absSin + size.height * absCos
        )
        
        let format = UIGraphicsImageRendererFormat()
        // 旋转后四角可能会留空，这里需要透明背景
        // opaque=true 则留空区域为黑色
        format.opaque = false
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        
        let image = renderer.image { ctx in
            let cgContext = ctx.cgContext
            
            // CTM 变换步骤（User Space → Device Space）：
            // 1. 移动坐标系，将原点从画布左上角移到画布中心，使后续旋转以画布中心为锚点
            cgContext.translateBy(x: canvasSize.width / 2, y: canvasSize.height / 2)
            // 2. 旋转坐标系（正值为顺时针，因 UIKit 坐标系 Y 轴向下）
            cgContext.rotate(by: radians)
            // 3. 水平镜像：X 轴取反实现左右翻转
            if mirrored { cgContext.scaleBy(x: -1, y: 1) }
            
            // 以变换后的原点（画布中心）为基准，居中绘制原始尺寸图片
            draw(
                in: .init(
                    x: -size.width / 2,
                    y: -size.height / 2,
                    width: size.width,
                    height: size.height
                )
            )
        }
        return image.withRenderingMode(renderingMode)
    }
    
}
