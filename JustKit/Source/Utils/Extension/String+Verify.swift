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
    
    /// 是否包含中文字符（CJK 统一汉字基本区 U+4E00...U+9FFF）
    var hasChinese: Bool {
        contains { ("\u{4e00}"..."\u{9fff}").contains($0) }
    }
    
    /// 是否匹配任意正则式
    func matches(_ rule: Rule) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", rule.rawValue).evaluate(with: self)
    }
    
}

public extension String {
 
    /// 正则匹配规则
    ///
    /// 使用预定义规则或通过 `.custom("正则表达式")` 自定义规则
    /// - 示例：`"你好".matches(.chinese)` / `"abc".matches(.custom("^[a-z]+$"))`
    ///
    /// 常用正则语法速查：
    /// - `^` / `$`：匹配开头 / 结尾
    /// - `[]`：字符集，如 `[a-z]` 匹配小写字母
    /// - `{n}`：精确重复 n 次；`{n,m}`：重复 n 到 m 次
    /// - `+`：1 次或多次；`*`：0 次或多次；`?`：0 次或 1 次
    /// - `\d`：数字（NSPredicate 中需写 `[0-9]`）
    /// - `|`：或，如 `(a|b)` 匹配 a 或 b
    struct Rule {
        public let rawValue: String
        public init(_ rawValue: String) { self.rawValue = rawValue }
        public static func custom(_ pattern: String) -> Rule { Rule(pattern) }
        
        public static let chinese = Rule("^[\u{4e00}-\u{9fff}]+$")
        public static let number = Rule("^[0-9]+$")
        public static let letter = Rule("^[a-zA-Z]+$")
        public static let lower = Rule("^[a-z]+$")
        public static let upper = Rule("^[A-Z]+$")
        public static let letterAndNumber = Rule("^[a-zA-Z0-9]+$")
        public static let lowerAndNumber = Rule("^[a-z0-9]+$")
        public static let upperAndNumber = Rule("^[A-Z0-9]+$")
    }
    
}
