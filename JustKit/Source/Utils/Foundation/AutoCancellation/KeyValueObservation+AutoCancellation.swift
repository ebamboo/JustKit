//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

// MARK: - 自动取消

public extension NSKeyValueObservation {
    
    /// 将 KVO 观察的生命周期存储到 owner
    ///
    /// owner 释放时观察自动取消。
    ///
    /// - Note: 闭包**强捕获** self（NSKeyValueObservation）。
    ///   与 Timer、CADisplayLink、通知观察者不同（它们由 RunLoop 或 NotificationCenter 外部持有），
    ///   NSKeyValueObservation 没有外部持有者，
    ///   若使用 `[weak self]` 则观察对象会在 `store(on:)` 返回后立即释放，观察随之失效。
    ///   强捕获使持有链为：owner → token → closure → NSKeyValueObservation，
    ///   owner 释放时链路断开，observation 释放并自动取消观察。
    ///
    /// ## 示例
    /// ```swift
    /// scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
    ///     self?.handleScroll(scrollView)
    /// }.store(on: self)
    /// ```
    func store(on owner: NSObject) {
        // 强捕获 self：闭包持有 observation，确保观察在 owner 存活期间有效
        let token = AutoCancellationToken { _ = self }
        owner.autoCancellationTokens.append(token)
    }
    
}
