//
//  Created by 姚旭 on 2025/9/28.
//

import UIKit

public extension NSObject {
    
    /// 订阅键盘相关事件
    /// - NOTE:  仅订阅了 keyboardWillShowNotification 和 keyboardWillHideNotification
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
        keyboardEventSubscription = subscription
    }
    
    /// 键盘相关信息
    struct KeyboardInfo {
        let isLocal: Bool
        let frameBegin: CGRect
        let frameEnd: CGRect
        let animationDuration: TimeInterval
        let animationCurve: UIView.AnimationOptions
        init?(_ notification: Notification) {
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
    
    static var keyboard_event_subscription_key = "keyboard_event_subscription_key"
    var keyboardEventSubscription: KeyboardEventSubscription? {
        get {
            withUnsafePointer(to: &Self.keyboard_event_subscription_key) { key in
                objc_getAssociatedObject(self, key) as? KeyboardEventSubscription
            }
        }
        set {
            withUnsafePointer(to: &Self.keyboard_event_subscription_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    class KeyboardEventSubscription {
        var eventBlock: ((Bool, KeyboardInfo?) -> Void)?
        weak var observerForShow: NSObjectProtocol?
        weak var observerForHide: NSObjectProtocol?
        deinit {
            if let observerForShow {
                NotificationCenter.default.removeObserver(observerForShow)
            }
            if let observerForHide {
                NotificationCenter.default.removeObserver(observerForHide)
            }
        }
    }
    
}
