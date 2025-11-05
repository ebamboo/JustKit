//
//  Created by 姚旭 on 2021/4/24.
//

import UIKit

public extension UIColor {
    
    /// 接受一个6位十六机制正整数
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 08) & 0xFF) / 255.0
        let b = CGFloat((hex >> 00) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 接受6或8位长度的十六进制字符串，开头可以包含 "#"
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
    
    /// 获取十六进制字符串
    /// 注意：1. 返回的字符串头部不添加添加 "#" 2. 其中字母均为大写字母
    /// needAlpha 表示在 alpha 为 1.0时，是否需要把 alpha 包含在十六进制字符串中
    /// alpha  小于 1.0 时，总会把 alpha 信息包含在字符串中
    func hexString(needAlpha: Bool = true) -> String? {
        guard let couple = rgb else { return nil }
        let redInt = Int(couple.r * 255)
        let greenInt = Int(couple.g * 255)
        let blueInt = Int(couple.b * 255)
        let alphaInt = Int(couple.alpha * 255)
        if couple.alpha < 1.0 {
            return String(format: "%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
        } else {
            return String(format: "%02X%02X%02X\(needAlpha ? "FF" : "")", redInt, greenInt, blueInt)
        }
    }
    
    /// 使用 [0~255] 范围的 RGB 初始化颜色
    convenience init(r255: Int, g255: Int, b255: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat(r255) / 255.0
        let g = CGFloat(g255) / 255.0
        let b = CGFloat(b255) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// 获取 rgb和alpha，均为 0-1 之间小数
    /// 非标准 RGB 颜色或者无效的 UIColor 对象等情况可能获取失败
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
    
    /// 获取一个随机颜色
    static var random: UIColor {
        let r = CGFloat(arc4random_uniform(256)) / 255.0
        let g = CGFloat(arc4random_uniform(256)) / 255.0
        let b = CGFloat(arc4random_uniform(256)) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}
