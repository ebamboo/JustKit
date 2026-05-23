//
//  Created by 姚旭 on 2022/8/7.
//

import UIKit

// MARK: - ================ Timer ==================
// MARK: -

public extension Timer {
    
    func managed(by owner: NSObject) {
        owner.wrappedTimers.append(NSObject.WrappedTimer(self))
    }
    
}

private extension NSObject {
    
    static var wrapped_timers_key: Void?
    var wrappedTimers: [WrappedTimer] {
        get {
            objc_getAssociatedObject(self, &Self.wrapped_timers_key) as? [WrappedTimer] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.wrapped_timers_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class WrappedTimer {
        weak var timer: Timer?
        init(_ timer: Timer) { self.timer = timer }
        deinit { timer?.invalidate() }
    }
    
}

// MARK: - ================ CADisplayLink ==================
// MARK: -

public extension CADisplayLink {
    
    func managed(by owner: NSObject) {
        owner.wrappedDisplayLinks.append(NSObject.WrappedDisplayLink(self))
    }
    
}

private extension NSObject {
    
    static var wrapped_displaylinks_key: Void?
    var wrappedDisplayLinks: [WrappedDisplayLink] {
        get {
            objc_getAssociatedObject(self, &Self.wrapped_displaylinks_key) as? [WrappedDisplayLink] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.wrapped_displaylinks_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class WrappedDisplayLink {
        weak var displaylink: CADisplayLink?
        init(_ displaylink: CADisplayLink) { self.displaylink = displaylink }
        deinit { displaylink?.invalidate() }
    }
    
}

// MARK: - ============ NotificationCenter =============
// MARK: -

public extension NSObjectProtocol {
    
    func managed(by owner: NSObject) {
        owner.wrappedNotificationObservers.append(NSObject.WrappedNotificationObserver(self))
    }

}

private extension NSObject {
    
    static var wrapped_notification_observers_key: Void?
    var wrappedNotificationObservers: [WrappedNotificationObserver] {
        get {
            objc_getAssociatedObject(self, &Self.wrapped_notification_observers_key) as? [WrappedNotificationObserver] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.wrapped_notification_observers_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class WrappedNotificationObserver {
        weak var observer: NSObjectProtocol?
        init(_ observer: NSObjectProtocol) { self.observer = observer }
        deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    
}

// MARK: - ================= KVO ===================
// MARK: -

public extension NSKeyValueObservation {
    
    func managed(by owner: NSObject) {
        owner.keyValueObservations.append(self)
    }
    
}

private extension NSObject {

    static var key_value_observations_key: Void?
    var keyValueObservations: [NSKeyValueObservation] {
        get {
            objc_getAssociatedObject(self, &Self.key_value_observations_key) as? [NSKeyValueObservation] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.key_value_observations_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
