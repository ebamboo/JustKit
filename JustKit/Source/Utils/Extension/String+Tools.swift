//
//  Created by 姚旭 on 2021/4/22.
//

import UIKit

public extension String {
    
    /// 给定 font 和 width 计算多行字符串所占用尺寸的高度
    func height(font: UIFont, width: CGFloat) -> CGFloat {
        let text = self as NSString
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = [NSAttributedString.Key.font: font]
        let rect = text.boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return rect.size.height + 1
    }
    
    /// 给定 font 计算单行字符串所占用尺寸的宽度
    func width(font: UIFont) -> CGFloat {
        let text = self as NSString
        let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
        return size.width + 1
    }
    
    /// URL方式编码字符串
    /// 除指定字符外，其他所有的字符都用百分号形式表示
    /// 适用场景：遍历 query 参数字典，对 value 进行编码，然后拼接至 URL
    var urlEncoded: String? {
        // RFC 3986 unreserved set
        let unreserved = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        )
        return addingPercentEncoding(withAllowedCharacters: unreserved)
    }
    
}
