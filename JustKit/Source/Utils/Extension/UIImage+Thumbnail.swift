//
//  Created by 姚旭 on 2021/4/25.
//

import UIKit

///
/// # 图片降采样 / 缩略图
///
/// iOS 15+ 推荐使用系统方法：
/// - `preparingThumbnail(of:)` 同步方法
/// - `prepareThumbnail(of:completionHandler:)` 异步方法
///
/// ## size 参数说明
/// - 单位为**像素（px）**，不是逻辑点（pt）。
/// - 内部实现算法：取 max(size.width, size.height) 作为结果图片的长边，等比缩放（可放大可缩小）。
/// - 返回的 UIImage 的 scale 固定为 1.0。
///
/// ## 用于显示的标准用法
/// ```
/// let scale = UIScreen.main.scale
/// let targetSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
/// let thumbnail = image.preparingThumbnail(of: targetSize)
/// ```
///
/// ## 注意事项
/// - UIImage(data:) 创建后可立即获取 size（只读 header，不解码），用于判断是否需要降采样。
/// - 原图小于 targetSize 时会被放大，如需"只缩不放"需自行判断。
/// - 非正方形 targetSize 时，其过程和结果等效为 targetSize 长边组成的正方形。
///

///
/// 苹果提供的图片压缩法
/// Downsampling large images for display at smaller size
/// https://developer.apple.com/videos/play/wwdc2018/219/?time=26
///

//public extension UIImage {
//    
//    static func downsample(image data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
//        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//        let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions)!
//        
//        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
//        let downsampleOptions = [
//            kCGImageSourceCreateThumbnailFromImageAlways: true,
//            kCGImageSourceShouldCacheImmediately: true,
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
//        ] as [CFString : Any] as CFDictionary
//        
//        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
//        return UIImage(cgImage: downsampledImage)
//    }
//
//    static func downsample(image url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
//        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
//        let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions)!
//        
//        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
//        let downsampleOptions = [
//            kCGImageSourceCreateThumbnailFromImageAlways: true,
//            kCGImageSourceShouldCacheImmediately: true,
//            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
//        ] as [CFString : Any] as CFDictionary
//        
//        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
//        return UIImage(cgImage: downsampledImage)
//    }
//    
//}
