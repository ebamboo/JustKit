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
    
    static var wrapped_timers_key = "wrapped_timers_key"
    var wrappedTimers: [WrappedTimer] {
        get {
            withUnsafePointer(to: &Self.wrapped_timers_key) { key in
                objc_getAssociatedObject(self, key) as? [WrappedTimer] ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.wrapped_timers_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
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
    
    static var wrapped_displaylinks_key = "wrapped_displaylinks_key"
    var wrappedDisplayLinks: [WrappedDisplayLink] {
        get {
            withUnsafePointer(to: &Self.wrapped_displaylinks_key) { key in
                objc_getAssociatedObject(self, key) as? [WrappedDisplayLink] ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.wrapped_displaylinks_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
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
    
    static var wrapped_notification_observers_key = "wrapped_notification_observers_key"
    var wrappedNotificationObservers: [WrappedNotificationObserver] {
        get {
            withUnsafePointer(to: &Self.wrapped_notification_observers_key) { key in
                objc_getAssociatedObject(self, key) as? [WrappedNotificationObserver] ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.wrapped_notification_observers_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
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

    static var key_value_observations_key = "key_value_observations_key"
    var keyValueObservations: [NSKeyValueObservation] {
        get {
            withUnsafePointer(to: &Self.key_value_observations_key) { key in
                objc_getAssociatedObject(self, key) as? [NSKeyValueObservation] ?? []
            }
        }
        set {
            withUnsafePointer(to: &Self.key_value_observations_key) { key in
                objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}
