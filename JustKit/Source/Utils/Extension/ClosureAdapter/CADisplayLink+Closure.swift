//
//  Created by 姚旭 on 2026/5/28.
//

import UIKit

///
/// 为 `CADisplayLink` 提供基于闭包的事件处理，替代传统的 target-action 模式。
///
/// 每个 `CADisplayLink` 实例对应一个 handler。
///
public extension CADisplayLink {
    
    /// 使用闭包创建 CADisplayLink。
    ///
    /// 创建后 DisplayLink 处于暂停状态，需调用 `add(to:forMode:)` 启动。
    ///
    /// - Parameter handler: 每帧刷新时执行的闭包。
    ///
    /// - Important: `CADisplayLink` 被加入 RunLoop 后由 RunLoop 强持有，
    ///   不会因为外部无引用而自动停止，必须显式调用 `invalidate()` 才能停止并释放。
    ///
    /// - Note: 生命周期管理有两种方式：
    ///
    ///   **手动管理** — 自行持有并在合适时机调用 `invalidate()`：
    ///   ```swift
    ///   self.displayLink = CADisplayLink { [weak self] link in
    ///       self?.update(link)
    ///   }
    ///   self.displayLink?.add(to: .main, forMode: .common)
    ///   // 需要停止时
    ///   self.displayLink?.invalidate()
    ///   self.displayLink = nil
    ///   ```
    ///
    ///   **自动管理** — 通过 `store(on:)` 将生命周期绑定到 owner，owner 释放时自动 invalidate：
    ///   ```swift
    ///   let link = CADisplayLink { [weak self] displayLink in
    ///       self?.update(displayLink)
    ///   }
    ///   link.add(to: .main, forMode: .common)
    ///   link.store(on: self)
    ///   ```
    convenience init(handler: @escaping (CADisplayLink) -> Void) {
        self.init(
            target: ClosureProxy(handler: handler),
            selector: #selector(ClosureProxy.invoke(_:))
        )
    }
    
}

private extension CADisplayLink {
    
    /// CADisplayLink 的 target 对象，将 action 转发给闭包
    class ClosureProxy: NSObject {
        let handler: (CADisplayLink) -> Void
        init(handler: @escaping (CADisplayLink) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: CADisplayLink) {
            handler(sender)
        }
    }
    
}
