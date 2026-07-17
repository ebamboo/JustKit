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
    /// // 2. 通过 KVO 监听 UITextView 文字变化（仅代码赋值触发，用户输入不触发）
    /// textView.publisher(for: \.text)
    ///     .sink { [weak self] text in
    ///         self?.handleTextChange(text)
    ///     }
    ///     .store(in: &objc_cancellables)
    ///
    /// // 3. 通过 Notification 监听 UITextView 输入变化（仅用户输入触发，代码赋值不触发）
    /// NotificationCenter.default
    ///     .publisher(for: UITextView.textDidChangeNotification, object: textView)
    ///     .compactMap { ($0.object as? UITextView)?.text }
    ///     .sink { [weak self] text in
    ///         self?.handleUserInput(text)
    ///     }
    ///     .store(in: &objc_cancellables)
    ///
    /// // 4. 需要重置所有订阅时，直接赋空集合
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
