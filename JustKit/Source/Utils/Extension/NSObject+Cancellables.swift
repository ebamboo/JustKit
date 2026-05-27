//
//  Created by 姚旭 on 2025/9/30.
//

import Foundation
import Combine

public extension NSObject {
    
    /// 为 NSObject 提供的 Combine 订阅容器
    ///
    /// - Note:
    ///   - 确保在主线程操作
    ///
    /// **示例：**
    /// ```swift
    /// // 1. 在 UIViewController 中订阅 Publisher
    /// viewModel.$title
    ///     .receive(on: .main)
    ///     .sink { [weak self] title in
    ///         self?.titleLabel.text = title
    ///     }
    ///     .store(in: &objc_cancellables)
    ///
    /// // 2. 同时管理多个订阅
    /// NotificationCenter.default
    ///     .publisher(for: UIApplication.didBecomeActiveNotification)
    ///     .sink { [weak self] _ in
    ///         self?.refreshData()
    ///     }
    ///     .store(in: &objc_cancellables)
    ///
    /// // 3. 需要重置所有订阅时，直接赋空集合
    /// objc_cancellables = []
    /// ```
    var objc_cancellables: Set<AnyCancellable> {
        get {
            objc_getAssociatedObject(self, &Self.objc_cancellables_key) as? Set<AnyCancellable> ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.objc_cancellables_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

private extension NSObject {
    
    static var objc_cancellables_key: Void?
    
}
