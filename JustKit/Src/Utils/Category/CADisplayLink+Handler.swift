//
//  Created by 姚旭 on 2025/7/4.
//

import UIKit

public extension CADisplayLink {
    
    /// 直接以闭包handler的形式初始化 CADisplayLink
    /// 可以有效避免 “使用 Target 方法时引起的强引用进而造成循环引用和内存泄漏的问题”
    convenience init(handler: @escaping (CADisplayLink) -> Void) {
        self.init(target: DisplayLinkTarget(handler: handler), selector: #selector(DisplayLinkTarget.invoke(_:)))
    }
    
}

private extension CADisplayLink {
    
    class DisplayLinkTarget {
        var handler: (CADisplayLink) -> Void
        init(handler: @escaping (CADisplayLink) -> Void) {
            self.handler = handler
        }
        @objc func invoke(_ sender: CADisplayLink) {
            handler(sender)
        }
    }
    
}
