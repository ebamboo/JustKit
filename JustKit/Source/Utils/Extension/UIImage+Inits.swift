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
    
    /// 颜色转为 UIImage
    convenience init?(color: CGColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color)
        context.fill(CGRect(origin: .zero, size: size))
        guard let cgImage  = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    /// UIView 转为 UIImage
    convenience init?(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        guard let cgImage  = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
}

private extension UIImage {
    
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
    
    static func image(
        with color: UIColor,
        size: CGSize = CGSize(width: 1, height: 1),
        scale: CGFloat = 1
    ) -> UIImage {
        
        UIImage(named: "")!
    }
    
}
