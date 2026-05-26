//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

// MARK: - 自动取消

public extension NSObjectProtocol {
    
    /// 将通知观察者的生命周期存储到 owner
    ///
    /// owner 释放时自动调用 `NotificationCenter.default.removeObserver(_:)`
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// - Note: 闭包**弱捕获** self（observer 对象）。
    ///   NotificationCenter 外部持有 observer，即使闭包不强持有，observer 仍存活直到被 remove。
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有 `addObserver(forName:...)` 返回的观察者对象，
    /// 并在合适时机调用 `removeObserver(_:)` 移除：
    /// ```swift
    /// // 手动管理
    /// self.observer = NotificationCenter.default
    ///     .addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
    ///         // ...
    ///     }
    /// // 需要停止时
    /// if let observer = self.observer {
    ///     NotificationCenter.default.removeObserver(observer)
    /// }
    /// self.observer = nil
    /// ```
    ///
    /// ## 示例
    /// ```swift
    /// NotificationCenter.default
    ///     .addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
    ///         // ...
    ///     }
    ///     .store(on: self)
    /// ```
    func store(on owner: NSObject) {
        let token = AutoCancellationToken { [weak self] in
            if let self {
                NotificationCenter.default.removeObserver(self)
            }
        }
        owner.autoCancellationTokens.append(token)
    }
    
}
