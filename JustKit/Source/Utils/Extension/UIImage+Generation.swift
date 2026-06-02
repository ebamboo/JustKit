//
//  Created by 姚旭 on 2022/7/3.
//

import UIKit
import CoreImage.CIFilterBuiltins

public extension UIImage {
    
    // MARK: - 颜色生图
    
    /// 创建指定颜色和尺寸的纯色图片
    ///
    /// 内部使用 UIGraphicsImageRenderer 绘制，
    /// 输出图片的 opaque 为 false、scale 跟随屏幕分辨率
    ///
    /// - Parameters:
    ///   - color: 填充颜色
    ///   - size: 图片尺寸，默认 1×1 pt
    /// - Returns: 纯色填充的 UIImage
    static func filled(
        with color: UIColor,
        size: CGSize = .init(width: 1, height: 1)
    ) -> UIImage {
        let safeSize = size.width > 0 && size.height > 0
            ? size
            : .init(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: safeSize)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(.init(origin: .zero, size: safeSize))
        }
    }
    
    // MARK: - 动态外观适配
    
    /// 创建 能随 UITraitCollection 变化而自动切换外观的 图片
    ///
    /// 内部通过 UIImageAsset 注册不同 trait 对应的图片变体，
    /// 当系统外观（如 Light/Dark Mode）发生切换时，UIKit 会自动选择匹配的变体进行显示。
    ///
    /// - Parameters:
    ///   - traits: 需要适配的 trait 集合，默认为 Light 和 Dark 两种外观模式
    ///   - provider: 根据给定 trait 返回对应图片的闭包
    /// - Returns: 与 UIImageAsset 关联的动态图片
    static func dynamic(
        for traits: [UITraitCollection] = [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(userInterfaceStyle: .dark)
        ],
        provider: (UITraitCollection) -> UIImage
    ) -> UIImage {
        guard !traits.isEmpty else { fatalError("traits 不可为空") }
        let asset = UIImageAsset()
        for trait in traits {
            let image = provider(trait)
            asset.register(image, with: trait)
        }
        // 返回的 UIImage 通过 imageAsset 属性强引用 UIImageAsset，
        // 因此局部变量 asset 不会被释放，图片能持续响应 trait 变化并自动切换变体。
        return asset.image(with: .current)
    }
    
    // MARK: - 生成二维码
    
    /// 二维码纠错等级
    ///
    /// 纠错等级越高，二维码可被遮挡或污损的面积越大，
    /// 但可编码的有效数据量会相应减少（更多空间用于存储纠错码字）。
    enum QRCorrectionLevel: String {
        /// 低纠错：约 7% 的码字可恢复
        case low = "L"
        /// 中等纠错：约 15% 的码字可恢复
        case medium = "M"
        /// 较高纠错：约 25% 的码字可恢复
        case quartile = "Q"
        /// 最高纠错：约 30% 的码字可恢复，适合需要在二维码中心叠加 Logo 的场景
        case high = "H"
    }
    
    /// 根据文本内容生成自定义颜色的二维码图片
    ///
    /// - Parameters:
    ///   - text: 要编码的文本内容（使用 UTF-8 编码）
    ///   - size: 输出图片的目标尺寸（二维码等比缩放后居中绘制，宽高不等时长边方向两侧为透明区域）
    ///   - correctionLevel: 纠错等级，默认 `.medium`
    ///   - foregroundColor: 码块颜色，默认黑色
    ///   - backgroundColor: 背景颜色，默认白色
    /// - Returns: 生成的二维码 UIImage；文本为空、size 无效或滤镜失败时返回 nil
    static func qrCode(
        from text: String,
        size: CGSize,
        correctionLevel: QRCorrectionLevel = .medium,
        foregroundColor: UIColor = .black,
        backgroundColor: UIColor = .white
    ) -> UIImage? {
        guard !text.isEmpty else { return nil }
        guard size.width > 0, size.height > 0 else { return nil }
        
        // 1. 通过 CIQRCodeGenerator 生成原始二维码 CIImage，
        // 此时图像非常小（通常仅 20~30 像素），且为黑白单通道。
        guard let qrCIImage = {
            let qrFilter = CIFilter.qrCodeGenerator()
            qrFilter.message = Data(text.utf8)
            qrFilter.correctionLevel = correctionLevel.rawValue
            return qrFilter.outputImage
        }() else { return nil }
        
        // 2. 通过 CIFalseColor 将黑白像素重新映射为指定的前景色和背景色。
        guard let coloredCIImage = {
            let colorFilter = CIFilter.falseColor()
            colorFilter.inputImage = qrCIImage
            colorFilter.color0 = CIColor(color: foregroundColor) // 对应亮度为 0 的像素，即原始黑色码块
            colorFilter.color1 = CIColor(color: backgroundColor) // 对应亮度为 1 的像素，即原始白色背景
            return colorFilter.outputImage
        }() else { return nil }
        
        // 3. 使用 CIContext 将着色后的 CIImage 渲染为 CGImage。
        guard let cgImage = CIContext().createCGImage(coloredCIImage, from: coloredCIImage.extent) else { return nil }
        
        // 4. 根据原始 extent 与目标 size 计算等比缩放比例，得到居中绘制区域。
        let drawRect = {
            let originalExtent = coloredCIImage.extent.integral
            let scale = min(size.width / originalExtent.width, size.height / originalExtent.height)
            let scaledWidth = originalExtent.width * scale
            let scaledHeight = originalExtent.height * scale
            return CGRect(
                x: (size.width - scaledWidth) * 0.5,
                y: (size.height - scaledHeight) * 0.5,
                width: scaledWidth,
                height: scaledHeight
            )
        }()
        
        // 5. 通过 UIGraphicsImageRenderer 将 CGImage 绘制到目标尺寸的画布中并导出 UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            ctx.cgContext.interpolationQuality = .none // 最近邻插值，避免缩放模糊，保持码块边缘锐利
            ctx.cgContext.draw(cgImage, in: drawRect)
        }
    }
    
}
