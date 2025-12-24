//
//  Created by 姚旭 on 2025/1/12.
//

import Foundation

/// Server-Sent Events (SSE) 事件模型
/// 遵循 W3C SSE 规范: https://html.spec.whatwg.org/multipage/server-sent-events.html
public struct SSEEvent {
    
    /// 事件类型，默认为 "message"
    public let event: String
    
    /// 事件数据内容，多行数据用换行符连接
    public let data: String
    
    /// 事件唯一标识符，用于断线重连时的 Last-Event-ID
    public let id: String?
    
    /// 重连延迟时间（毫秒），客户端应在连接断开后等待该时间再重连
    public let retry: Int?
    
}

public extension SSEEvent {
    
    init(from rawMessage: String) {
        var eventType = "message"
        var dataLines: [String] = []
        var lastEventId: String? = nil
        var retryTime: Int? = nil
        
        let lines = rawMessage.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            // 存储从 line 获取的字段名和字段值
            let couple: (field: String, value: String)
            
            // MARK: 处理行
            
            // 规范：以冒号 ":" 开头表示注释行，忽略
            if line.starts(with: ":") {
                continue
            }
            
            // 规范：包含冒号 ":"
            // 冒号前作为 field（字段名），冒号后的内容作为 value（字段值）。
            // 如果 value 首字符是空格，则去掉该空格。
            if let colonIndex = line.firstIndex(of: ":") {
                let field = line[..<colonIndex]
                var value = line[line.index(after: colonIndex)...]
                if value.starts(with: " ") {
                    value = value.dropFirst()
                }
                couple = (String(field), String(value))
            }
            
            // 规范：不包含冒号 ":"
            // 整行作为 field（字段名），value（字段值）为空字符串
            else {
                couple = (String(line), "")
            }
            
            // MARK: 处理字段
            
            switch couple.field {
            case "event":
                // 无条件，覆盖设置
                eventType = couple.value
            case "data":
                // 无条件，收集所有 data 字段
                dataLines.append(couple.value)
            case "id":
                // 满足条件，覆盖设置
                // 规范：If the field value does not contain U+0000 NULL,
                // then set the last event ID buffer to the field value.
                // Otherwise, ignore the field.
                if !couple.value.contains("\u{0}") {
                    lastEventId = couple.value
                }
            case "retry":
                // 满足条件，覆盖设置
                // 规范：If the field value consists of only ASCII digits,
                // then interpret the field value as an integer in base ten,
                // and set the event stream's reconnection time to that integer.
                // Otherwise, ignore the field.
                if !couple.value.isEmpty,
                   couple.value.allSatisfy({ $0.isASCII && $0.isNumber }),
                   let intVal = Int(couple.value) {
                    retryTime = intVal
                }
            default:
                // 规范：The field is ignored.
                continue
            }
        }
        
        self.init(
            event: eventType,
            data: dataLines.joined(separator: "\n"),
            id: lastEventId,
            retry: retryTime
        )
    }
    
}
