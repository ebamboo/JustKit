//
//  Created by 姚旭 on 2022/7/3.
//

import UIKit

public extension UIImage {
    
    /// 字符串转为二维码图片
    convenience init?(string: String, side: CGFloat = 300) {
        // 二维码滤镜名称固定写法 "CIQRCodeGenerator"
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setDefaults()
        // 设置输入数据
        filter.setValue(string.data(using: .utf8), forKey: "inputMessage")
        // 设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else { return nil }
        guard let cgImage = UIImage.transferToCGImage(from: ciImage, side: side) else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// 把不清晰的 ciImage 转为清晰的 cgImage
    static func transferToCGImage(from ciImage: CIImage, side: CGFloat = 300) -> CGImage? {
        // 1.
        let extent = ciImage.extent
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: extent) else { return nil }
        
        // 2.
        let scale = min(side/extent.size.width, side/extent.size.height) * UIScreen.main.scale
        let context_width = Int(extent.size.width * scale)
        let context_height = Int(extent.size.height * scale)
        
        // 3.
        guard let context = CGContext(data: nil, width: context_width, height: context_height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0) else { return nil }
        context.interpolationQuality = .none
        context.scaleBy(x: scale, y: scale)
        context.draw(cgImage, in: extent)
        
        // 4.
        return context.makeImage()
    }
    
}

public extension UIImage {
    
    /// 创建一张能随 UITraitCollection 变化自动切换外观的动态图片
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
    
    // opaque 系统默认值 false
    // scale 系统默认值 UIScreen.main.scale
    static func image(
        with color: UIColor,
        size: CGSize = .init(width: 1, height: 1)
    ) -> UIImage {
        let safeSize = size.width > 0 && size.height > 0
            ? size
            : .init(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: safeSize)
        return renderer.image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: safeSize))
        }
    }
    
    // opaque 系统默认值 false
    // scale 系统默认值 UIScreen.main.scale
    static func qrCode(
        from text: String,
        size: CGSize,
        foregroundColor: UIColor = .black,
        backgroundColor: UIColor = .white,
    ) -> UIImage? {
        return nil
    }
    
}
