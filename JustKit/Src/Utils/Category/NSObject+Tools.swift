//
//  Created by 姚旭 on 2021/4/25.
//

import Foundation

public extension NSObject {
    
    /// 倒计时功能
    /// 从 limit 秒开始，每 step 秒回调一次事件，直至小于等于 0 结束
    ///
    /// 注意：
    /// progress 和 completion 在主线程中执行
    /// !!! 返回的 DispatchSourceTimer 如果需要请使用弱引用，这样系统会自动管理 timer 内存 !!!
    @discardableResult
    func countdown(with limit: Int,
                   step: Int,
                   progress: @escaping (_ caller: NSObject?, _ remainder: Int) -> Void,
                   completion: @escaping (_ caller: NSObject?) -> Void) -> DispatchSourceTimer {
        weak var weakself = self
        var tempTime = limit
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: Double(step))
        timer.setEventHandler {
            if tempTime <= 0 {
                timer.cancel()
                DispatchQueue.main.async {
                    completion(weakself)
                }
            } else {
                DispatchQueue.main.async {
                    progress(weakself, tempTime)
                    tempTime -= step
                }
            }
        }
        timer.resume()
        return timer
    }
    
}
