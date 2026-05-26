//
//  Created by 姚旭 on 2022/7/1.
//

import Foundation

public extension String {
    
    /// 获取指定位置的单个字符
    /// "0123456"[3] 返回 "3"
    subscript(index: Int) -> String? {
        guard 0 <= index, index < count else { return nil }
        let i = self.index(startIndex, offsetBy: index)
        return String(self[i])
    }
    
    /// 获取闭区间范围的子字符串（包含两端）
    /// "0123456"[2...5] 返回 "2345"
    subscript(range: ClosedRange<Int>) -> String? {
        guard 0 <= range.lowerBound, range.upperBound < count else { return nil }
        let fromIndex = index(startIndex, offsetBy: range.lowerBound)
        let toIndex = index(fromIndex, offsetBy: range.upperBound - range.lowerBound)
        return String(self[fromIndex...toIndex])
    }
    
    /// 获取半开区间范围的子字符串（不包含上界）
    /// "0123456"[2..<5] 返回 "234"
    subscript(range: Range<Int>) -> String? {
        guard 0 <= range.lowerBound, range.upperBound <= count, !range.isEmpty else { return nil }
        let fromIndex = index(startIndex, offsetBy: range.lowerBound)
        let toIndex = index(fromIndex, offsetBy: range.upperBound - range.lowerBound)
        return String(self[fromIndex..<toIndex])
    }
    
    /// 获取从指定位置到末尾的子字符串（包含该位置）
    /// "0123456"[2...] 返回 "23456"
    subscript(range: PartialRangeFrom<Int>) -> String? {
        guard 0 <= range.lowerBound, range.lowerBound < count else { return nil }
        let fromIndex = index(startIndex, offsetBy: range.lowerBound)
        return String(self[fromIndex...])
    }
    
    /// 获取从开头到指定位置的子字符串（包含该位置）
    /// "0123456"[...4] 返回 "01234"
    subscript(range: PartialRangeThrough<Int>) -> String? {
        guard 0 <= range.upperBound, range.upperBound < count else { return nil }
        let toIndex = index(startIndex, offsetBy: range.upperBound)
        return String(self[...toIndex])
    }
    
    /// 获取从开头到指定位置的子字符串（不包含该位置）
    /// "0123456"[..<4] 返回 "0123"
    subscript(range: PartialRangeUpTo<Int>) -> String? {
        guard 0 < range.upperBound, range.upperBound <= count else { return nil }
        let toIndex = index(startIndex, offsetBy: range.upperBound)
        return String(self[..<toIndex])
    }
    
    /// 以指定位置为锚点，取 length 个字符；正数向右取，负数向左取，0 返回 nil
    /// - Parameters:
    ///   - position: 锚点位置（包含在结果中）
    ///   - length: 要取的字符个数；正数向右取，负数向左取
    ///
    /// "0123456".sub(at: 2, length: 3) 返回 "234"
    /// "0123456".sub(at: 4, length: -3) 返回 "234"
    func sub(at position: Int, length: Int) -> String? {
        guard length != 0 else { return nil }
        let lower = length > 0 ? position : position + length + 1
        let upper = length > 0 ? position + length - 1 : position
        guard 0 <= lower, upper < count else { return nil }
        let fromIndex = index(startIndex, offsetBy: lower)
        let toIndex = index(fromIndex, offsetBy: upper - lower)
        return String(self[fromIndex...toIndex])
    }
    
}
