//
//  Created by 姚旭 on 2022/8/7.
//

import Foundation

/// 限制任务在 App 生命周期内的执行次数。
///
/// 同一 `label` 的任务最多执行 `limit` 次。
/// 首次调用时指定的 `limit` 会被记录，后续调用即使传入不同的 `limit` 也将忽略。
///
/// - Note:
///   对于 NSObject 实例级别的“一次性执行”需求，优先使用 `lazy` 属性实现。
///   若需要限制对象生命周期内的执行次数，则应由对象自行维护计数状态。
public enum ExecutionLimiter {
    
    private static var storage: [String: Int] = [:]
    private static let lock = NSLock()
    
    /// - Parameters:
    ///   - label: 任务标识，相同 label 共享执行次数。
    ///   - limit: 最大执行次数，仅首次调用时生效。
    ///   - work: 需要执行的任务。
    public static func perform(
        label: String,
        limit: Int = 1,
        work: () -> Void
    ) {
        lock.lock()
        let remain = storage[label] ?? limit
        // 保证首次调用时必然注册 limit，后续调用不再重新注册。
        storage[label] = remain
        guard remain > 0 else {
            lock.unlock()
            return
        }
        storage[label] = remain - 1
        lock.unlock()
        work()
    }
    
}
