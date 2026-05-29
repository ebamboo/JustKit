//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

public extension NSObjectProtocol {
    
    /// 将通知观察者的生命周期存储到 owner
    ///
    /// owner 释放时自动调用 `NotificationCenter.default.removeObserver(_:)`。
    ///
    /// - Important: 必须在主线程调用。
    ///
    /// ```swift
    /// // 自动管理 — 通过 store(on:) 绑定到 owner 生命周期
    /// NotificationCenter.default
    ///     .addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
    ///         // ...
    ///     }
    ///     .store(on: self)
    /// ```
    ///
    /// 若不使用 `store(on:)` 自动管理，可手动持有观察者对象并在合适时机调用 `removeObserver(_:)`：
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
    func store(on owner: NSObject) {
        // 弱捕获 self：NotificationCenter 外部持有 observer，即使闭包不强持有，observer 仍存活直到被 remove
        let cancellable = AutoCancellable { [weak self] in
            if let self {
                NotificationCenter.default.removeObserver(self)
            }
        }
        owner.autoCancellables.append(cancellable)
    }
    
}
