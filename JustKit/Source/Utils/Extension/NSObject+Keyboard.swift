//
//  Created by 姚旭 on 2025/9/28.
//

import UIKit

public extension NSObject {
    
    /// 订阅键盘事件
    ///
    /// - Parameters:
    ///   - block: 键盘事件回调，isDocked 为 true 表示键盘弹出，false 表示收起
    ///
    /// - Note:
    ///   - 仅订阅 keyboardWillShowNotification 和 keyboardWillHideNotification
    ///   - 回调在主线程执行
    ///   - 调用者释放时，自动取消订阅
    ///   - 重复调用时自动取消上一次订阅
    ///   - 可通过 `unsubscribeFromKeyboardEvents()` 主动取消订阅
    func subscribeToKeyboardEvents(with block: @escaping (_ isDocked: Bool, _ info: KeyboardInfo?) -> Void) {
        let subscription = KeyboardEventSubscription()
        subscription.eventBlock = block
        subscription.observerForShow = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.keyboardEventSubscription?.eventBlock?(true, .init(notification))
        }
        subscription.observerForHide = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.keyboardEventSubscription?.eventBlock?(false, .init(notification))
        }
        // 替换关联对象 → 旧 subscription 释放 → deinit 自动移除旧通知观察者
        keyboardEventSubscription = subscription
    }
    
    /// 主动取消订阅键盘事件
    func unsubscribeFromKeyboardEvents() {
        // 置 nil → subscription 释放 → deinit 自动移除通知观察者
        keyboardEventSubscription = nil
    }
    
    /// 键盘事件信息
    struct KeyboardInfo {
        public let isLocal: Bool
        public let frameBegin: CGRect
        public let frameEnd: CGRect
        public let animationDuration: TimeInterval
        public let animationCurve: UIView.AnimationOptions
        fileprivate init?(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let isLocal = userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
                  let frameBegin = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
                  let frameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return nil }
            self.isLocal = isLocal
            self.frameBegin = frameBegin
            self.frameEnd = frameEnd
            self.animationDuration = animationDuration
            self.animationCurve = .init(rawValue: animationCurve << 16)
        }
    }
    
}

private extension NSObject {
    
    /// 用于访问关联的 键盘事件订阅对象 的 key
    static var keyboard_event_subscription_key: Void?
    
    /// 关联的 键盘事件订阅对象
    var keyboardEventSubscription: KeyboardEventSubscription? {
        get {
            objc_getAssociatedObject(self, &Self.keyboard_event_subscription_key) as? KeyboardEventSubscription
        }
        set {
            objc_setAssociatedObject(self, &Self.keyboard_event_subscription_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 键盘事件订阅对象，管理 通知观察者 生命周期
    class KeyboardEventSubscription {
        var eventBlock: ((Bool, KeyboardInfo?) -> Void)?
        weak var observerForShow: NSObjectProtocol?
        weak var observerForHide: NSObjectProtocol?
        deinit {
            // 释放时自动移除通知观察者
            if let observerForShow {
                NotificationCenter.default.removeObserver(observerForShow)
            }
            if let observerForHide {
                NotificationCenter.default.removeObserver(observerForHide)
            }
        }
    }
    
}
