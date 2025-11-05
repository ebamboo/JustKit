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
    
    /// 打电话
    func call() {
        if let url = URL(string: "telprompt://\(self)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    /// 把字符串中汉字转换为拼音（小写字母）
    /// 注意：返回结果已去除了其中的 " " 字符串
    /// 举例：
    /// "你好".pinyin 结果为 "nihao"
    /// "1a《混合".pinyin 结果为 "1a《hunhe"
    /// "".pinyin 结果为 ""
    var pinyin: String? {
        guard let temp = self.applyingTransform(.mandarinToLatin, reverse: false) else { return nil }
        guard let temp = temp.applyingTransform(.stripDiacritics, reverse: false) else { return nil }
        return temp.replacingOccurrences(of: " ", with: "")
    }
    
    /// URL方式编码字符串；
    /// 大小写字母和数字不被编码；其他所有的字符都用百分号形式表示（URL表示）；
    /// 适用场景：遍历参数字典，对value 进行编码，之后拼接至 URL;
    /// 注意：不要在拼接 URL 之后再调用，这会把 大小写字母和数字 之外的所有字符编码；
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }
    
}
