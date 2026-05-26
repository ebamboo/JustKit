//
//  Created by 姚旭 on 2021/4/24.
//

import UIKit

public extension UIColor {
    
    /// 使用 0~255 整数创建颜色
    /// `UIColor(red255: 254, green255: 140, blue255: 0)`
    convenience init(red255: Int, green255: Int, blue255: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat(red255) / 255.0
        let g = CGFloat(green255) / 255.0
        let b = CGFloat(blue255) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 使用十六进制整数创建颜色
    /// `UIColor(hex: 0xFE8C00)`
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 08) & 0xFF) / 255.0
        let b = CGFloat((hex >> 00) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 使用十六进制字符串创建颜色
    ///
    /// - 字符串大小写不敏感
    /// - 支持 6 位（`RRGGBB`）或 8 位（`RRGGBBAA`）格式，长度不计前缀。
    /// - 字符串可以带有 `#`、`0x` 或 `0X` 前缀，也可以完全不包含前缀。
    ///
    /// ```swift
    /// UIColor(hex: "#FE8C00")
    /// UIColor(hex: "0xfe8c00")
    /// UIColor(hex: "FE8C0080")
    /// ```
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        } else if hexString.hasPrefix("0X") {
            hexString.removeFirst(2)
        }
        if hexString.count == 6 {
            hexString.append("FF")
        }
        guard hexString.count == 8, let hexInt = Int(hexString, radix: 16) else { return nil }
        let r      = CGFloat((hexInt >> 24) & 0xFF) / 255.0
        let g      = CGFloat((hexInt >> 16) & 0xFF) / 255.0
        let b      = CGFloat((hexInt >> 08) & 0xFF) / 255.0
        let alpha  = CGFloat((hexInt >> 00) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// RGBA 分量（0~1），非 RGB 颜色空间返回 nil
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var alpha: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &alpha) else { return nil }
        return (r, g, b, alpha)
    }
    
    /// 十六进制字符串（大写，无前缀），alpha < 1.0 时始终包含 alpha 分量
    func hexString(includeAlpha: Bool = true) -> String? {
        guard let rgba = rgba else { return nil }
        let r = Int(round(rgba.r * 255))
        let g = Int(round(rgba.g * 255))
        let b = Int(round(rgba.b * 255))
        let a = Int(round(rgba.alpha * 255))
        if rgba.alpha < 1.0 || includeAlpha {
            return String(format: "%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "%02X%02X%02X", r, g, b)
        }
    }
    
    /// 随机颜色（alpha 固定为 1.0）
    static var random: UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
    
}
