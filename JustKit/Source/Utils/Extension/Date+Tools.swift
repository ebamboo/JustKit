//
//  Created by 姚旭 on 2021/4/24.
//

import Foundation

public extension Date {
    
    /// date string 转为 Date
    ///
    /// - Parameters:
    ///   - dateString: 日期字符串
    ///   - dateFormat: 日期格式，如 "yyyy-MM-dd HH:mm:ss"
    ///   - timeZone: 时区，默认为当前时区
    init?(dateString: String, dateFormat: String, timeZone: TimeZone = .current) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone
        // en_US_POSIX 是符合 POSIX 标准的固定 locale，
        // 格式化行为完全由 dateFormat 决定，不受用户设备设置影响（如 12/24 小时制、地区语言等），
        // 适用于与服务器交互、持久化存储等需要稳定格式的场景
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        self = date
    }
    
    /// Date 转为 date string
    ///
    /// - Parameters:
    ///   - dateFormat: 日期格式，如 "yyyy-MM-dd HH:mm:ss"
    ///   - timeZone: 时区，默认为当前时区
    func dateString(with dateFormat: String, timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone
        // 使用固定 locale，确保输出格式稳定（详见上方 init 方法注释）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
    
    /// 指定日历的日期时间生成 Date
    ///
    /// - Parameters:
    ///   - year: 年
    ///   - month: 月
    ///   - day: 日
    ///   - hour: 时
    ///   - minute: 分
    ///   - second: 秒
    ///   - calendar: 日历，默认公历
    ///   - timeZone: 时区，默认为当前时区
    init?(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        calendar: Calendar = Calendar(identifier: .gregorian),
        timeZone: TimeZone = .current
    ) {
        let dateComponents = DateComponents(
            calendar: calendar,
            timeZone: timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
        guard let date = dateComponents.date else { return nil }
        self = date
    }
    
    /// 获取 Date 对应的农历日期 (年, 月, 日)
    ///
    /// 六十甲子纪年 + 农历月份 + 农历日期的中文表示
    /// - 支持闰月识别，闰月时月份前会加"闰"字
    /// - 使用北京时间（Asia/Shanghai）作为农历计算时区
    var chineseYearMonthDay: (year: String, month: String, day: String)? {
        var calendar = Calendar(identifier: .chinese)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        guard let yearInt = components.year,
              let monthInt = components.month,
              let dayInt = components.day else { return nil }
        // 边界检查，防止数组越界
        guard (1...60).contains(yearInt),
              (1...12).contains(monthInt),
              (1...30).contains(dayInt) else { return nil }
        let year = Self.chineseYears[yearInt - 1]
        let month = (components.isLeapMonth == true ? "闰" : "") + Self.chineseMonths[monthInt - 1]
        let day = Self.chineseDays[dayInt - 1]
        return (year, month, day)
    }
    
}

private extension Date {
    
    /// 六十甲子：天干（甲乙丙丁戊己庚辛壬癸）配地支（子丑寅卯辰巳午未申酉戌亥），60 年为一循环
    static let chineseYears = [
        "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
        "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
        "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
        "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
        "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
        "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
    ]
    
    /// 农历月份：正月至腊月（十一月称冬月，十二月称腊月）
    static let chineseMonths = [
        "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"
    ]
    
    /// 农历日期：初一至三十
    static let chineseDays = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]
    
}
