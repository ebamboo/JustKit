//
//  Created by 姚旭 on 2025/7/4.
//

import UIKit

///
/// # CADisplayLink 闭包初始化扩展
///
/// 将 target/selector 模式转化为闭包形式，使调用方可通过 `[weak self]` 主动打破循环引用。
///
/// ## 示例
/// ```swift
/// let link = CADisplayLink { [weak self] displayLink in
///     self?.update(displayLink)
/// }
/// link.add(to: .main, forMode: .common)
/// ```
///

public extension CADisplayLink {
    
    /// 以闭包形式初始化 CADisplayLink，替代 target/selector 模式
    convenience init(handler: @escaping (CADisplayLink) -> Void) {
        self.init(target: DisplayLinkTarget(handler: handler), selector: #selector(DisplayLinkTarget.invoke(_:)))
    }
    
}

private extension CADisplayLink {
    
    /// 中间代理对象，作为 CADisplayLink 的 target，将 selector 调用转发给闭包
    class DisplayLinkTarget: NSObject {
        let handler: (CADisplayLink) -> Void
        init(handler: @escaping (CADisplayLink) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: CADisplayLink) {
            handler(sender)
        }
    }
    
}
