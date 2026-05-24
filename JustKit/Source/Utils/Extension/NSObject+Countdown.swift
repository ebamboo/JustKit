//
//  Created by 姚旭 on 2021/4/25.
//

import Foundation


public extension NSObject {

    /// 开启倒计时
    ///
    /// 从 duration 秒开始，每 interval 秒触发一次 onTick，归零后触发 onFinish。
    /// 回调均在主线程执行。
    ///
    /// 生命周期自动管理：
    /// - 重复调用自动取消上一次倒计时
    /// - 宿主对象释放时自动取消
    /// - 可通过 `cancelCountdown()` 主动取消
    /// - App 进入后台再回前台，剩余时间基于绝对时间自动修正
    ///
    /// - Parameters:
    ///   - duration: 倒计时总时长（秒），默认 60
    ///   - interval: 触发间隔（秒），默认 1
    ///   - onTick: 每次触发回调，remaining 为剩余秒数
    ///   - onFinish: 倒计时结束回调
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
    
    static var countdown_context_key: Void?
    
    /// 通过关联对象绑定到宿主，借助 deinit 自动管理 timer 生命周期
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
            // cancel 后 GCD 释放对 source 的内部持有
            timer?.cancel()
            timer = nil
        }
        
        deinit {
            cancel()
        }
        
    }
    
}
