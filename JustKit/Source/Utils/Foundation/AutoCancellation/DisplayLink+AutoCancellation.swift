//
//  Created by 姚旭 on 2025/7/4.
//

import UIKit

// MARK: - 闭包初始化

///
/// 将 target/selector 模式转化为闭包形式，使调用方可通过 `[weak self]` 主动打破循环引用。
///
/// ## 示例
/// ```swift
/// let link = CADisplayLink { [weak self] displayLink in
///     self?.update(displayLink)
/// }
/// link.add(to: .main, forMode: .common)
/// link.store(on: self)
/// ```
///
public extension CADisplayLink {
    
    /// 以闭包形式初始化 CADisplayLink，替代 target/selector 模式
    convenience init(handler: @escaping (CADisplayLink) -> Void) {
        self.init(
            target: DisplayLinkTarget(handler: handler),
            selector: #selector(DisplayLinkTarget.invoke(_:))
        )
    }
    
    /// CADisplayLink 的 target 对象，将 action 转发给闭包
    private class DisplayLinkTarget: NSObject {
        let handler: (CADisplayLink) -> Void
        init(handler: @escaping (CADisplayLink) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: CADisplayLink) {
            handler(sender)
        }
    }
    
}

// MARK: - 自动取消

public extension CADisplayLink {
    
    /// 将 CADisplayLink 的生命周期存储到 owner
    ///
    /// owner 释放时自动调用 `invalidate()`
    ///
    /// - Note: 闭包**弱捕获** self（CADisplayLink）。
    ///   RunLoop 外部持有 CADisplayLink，即使闭包不强持有，DisplayLink 仍存活直到被 invalidate。
    func store(on owner: NSObject) {
        let token = AutoCancellationToken { [weak self] in
            self?.invalidate()
        }
        owner.autoCancellationTokens.append(token)
    }
    
}
