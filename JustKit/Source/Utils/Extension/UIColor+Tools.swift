//
//  Created by 姚旭 on 2021/4/24.
//

import UIKit

public extension UIColor {
    
    /// 使用 6 位十六进制正整数初始化颜色，如 `UIColor(hex: 0xFE8C00)`
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 08) & 0xFF) / 255.0
        let b = CGFloat((hex >> 00) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 使用 6 或 8 位十六进制字符串初始化颜色，开头可以包含 "#"
    ///
    /// 6 位格式为 RRGGBB，8 位格式为 RRGGBBAA
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
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
    
    /// 获取十六进制字符串（大写，不含 "#" 前缀）
    ///
    /// - Parameter needAlpha: alpha 为 1.0 时是否包含 alpha 信息，默认包含；alpha 小于 1.0 时总是包含
    func hexString(needAlpha: Bool = true) -> String? {
        guard let rgba = rgb else { return nil }
        // 使用 round 避免浮点截断导致的 off-by-one
        let r = Int(round(rgba.r * 255))
        let g = Int(round(rgba.g * 255))
        let b = Int(round(rgba.b * 255))
        let a = Int(round(rgba.alpha * 255))
        if rgba.alpha < 1.0 {
            return String(format: "%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "%02X%02X%02X\(needAlpha ? "FF" : "")", r, g, b)
        }
    }
    
    /// 使用 0~255 范围的 RGB 值初始化颜色
    convenience init(r255: Int, g255: Int, b255: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat(r255) / 255.0
        let g = CGFloat(g255) / 255.0
        let b = CGFloat(b255) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 获取 RGBA 分量，均为 0~1 之间的小数
    ///
    /// 非标准 RGB 颜色（如 pattern color）可能获取失败返回 nil
    var rgb: (r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &alpha) {
            return (r, g, b, alpha)
        } else {
            return nil
        }
    }
    
    /// 随机颜色（alpha 固定为 1.0）
    static var random: UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
    
}
