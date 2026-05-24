//
//  Created by 姚旭 on 2022/7/1.
//

import Foundation

public extension String {
    
    /// 是否为国内手机号（1 开头，第二位 2-9，共 11 位）
    var isPhone: Bool {
        let mobilePhone = "^1[2-9][0-9]{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", mobilePhone)
        return predicate.evaluate(with: self)
    }
    
    /// 是否为合法的 18 位身份证号（正则格式校验 + GB11643 校验码验证）
    var isID: Bool {
        // 一、正则判断：地区(6) + 出生年月日(8) + 顺序码(3) + 校验码(1)
        let ID = "^[1-9][0-9]{9}(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])[0-9]{3}[0-9X]$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", ID)
        guard predicate.evaluate(with: self) else { return false }
        
        // 二、GB11643 校验码验证：前 17 位加权求和，模 11 映射校验码，与末位比对
        let factors = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        var weightedSum = 0
        prefix(17).enumerated().forEach { (i, char) in
            weightedSum += char.wholeNumberValue! * factors[i]
        }
        let checkCodes = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]
        let checkCode = checkCodes[weightedSum % 11]
        let lastCode = String(last!)
        return checkCode == lastCode
    }
    
    /// 是否包含中文字符（CJK 统一汉字基本区 U+4E00...U+9FA5）
    var hasChinese: Bool {
        contains { ("\u{4e00}"..."\u{9fa5}").contains($0) }
    }
    
    /// 是否包含空格
    var hasSpace: Bool {
        return firstIndex(of: " ") != nil
    }
    
    /// 检查字符串是否匹配正则规则
    ///
    /// 使用预定义规则或 `.custom("自定义正则式")` 来检查
    ///
    /// "*" 表示 {0, }，"+" 表示 {1, }，"?" 表示 {0, 1}
    ///
    struct Rule {
        let rawValue: String
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        static func custom(_ pattern: String) -> Rule { Rule(pattern) }
        
        static let chinese = Rule("^[\u{4e00}-\u{9fa5}]+$")
        static let number = Rule("^[0-9]+$")
        static let letter = Rule("^[a-zA-Z]+$")
        static let lower = Rule("^[a-z]+$")
        static let upper = Rule("^[A-Z]+$")
        static let letterAndNumber = Rule("^[a-zA-Z0-9]+$")
        static let lowerAndNumber = Rule("^[a-z0-9]+$")
        static let upperAndNumber = Rule("^[A-Z0-9]+$")
    }
    func matches(_ rule: Rule) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", rule.rawValue).evaluate(with: self)
    }
    
}
