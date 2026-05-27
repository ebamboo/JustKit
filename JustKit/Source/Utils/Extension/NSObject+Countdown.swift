//
//  Created by 姚旭 on 2021/4/25.
//

import Foundation

public extension NSObject {

    /// 开启倒计时
    ///
    /// - Parameters:
    ///   - duration: 总时长（秒），默认 60
    ///   - interval: 触发间隔（秒），默认 1
    ///   - onTick: 每次触发回调，remaining 为剩余秒数（首次调用立即触发）
    ///   - onFinish: 倒计时归零回调
    ///
    /// - Note:
    ///   - onTick / onFinish 均在主线程执行
    ///   - App 进入后台再回前台，剩余时间基于绝对时间自动修正
    ///   - 调用者释放时，自动取消倒计时
    ///   - 重复调用时自动取消上一次倒计时
    ///   - 可通过 `cancelCountdown()` 主动取消倒计时
    func startCountdown(
        duration: Int = 60,
        interval: Int = 1,
        onTick: @escaping (_ remaining: Int) -> Void,
        onFinish: @escaping () -> Void
    ) {
        let context = CountdownContext()
        // 替换关联对象 → 旧 context 释放 → deinit 自动 cancel 旧 timer
        objc_setAssociatedObject(self, &Self.countdown_context_key, context, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        context.start(duration: duration, interval: interval, onTick: onTick, onFinish: onFinish)
    }
    
    /// 主动取消倒计时
    func cancelCountdown() {
        // 置 nil → context 释放 → deinit 自动 cancel timer
        objc_setAssociatedObject(self, &Self.countdown_context_key, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}

private extension NSObject {
    
    /// 用于访问关联对象的 key
    private static var countdown_context_key: Void?
    
    /// 倒计时上下对象，管理 timer 生命周期
    class CountdownContext {
        
        var timer: DispatchSourceTimer?
        
        func start(
            duration: Int,
            interval: Int,
            onTick: @escaping (_ remaining: Int) -> Void,
            onFinish: @escaping () -> Void
        ) {
            cancel()
            guard duration > 0, interval > 0 else { onFinish(); return }
            // 记录结束时间点，用绝对时间计算剩余秒数，避免后台挂起导致计时不准
            let endDate = Date().addingTimeInterval(TimeInterval(duration))
            let step = interval
            
            timer = DispatchSource.makeTimerSource(queue: .main)
            timer?.schedule(deadline: .now(), repeating: .seconds(step))
            timer?.setEventHandler { [weak self] in
                let remaining = Int(ceil(endDate.timeIntervalSinceNow))
                if remaining <= 0 {
                    self?.cancel()
                    onFinish()
                } else {
                    onTick(remaining)
                }
            }
            timer?.resume()
        }
        
        func cancel() {
            // cancel 后，GCD 释放对 timer source 的内部持有
            timer?.cancel()
            timer = nil
        }
        
        deinit {
            cancel()
        }
        
    }
    
}
