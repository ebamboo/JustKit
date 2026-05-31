//
//  Created by 姚旭 on 2021/11/28.
//

import UIKit

/// 模态滑动转场代理。
///
/// 为模态展示（Present）和关闭（Dismiss）提供滑动转场动画，
/// 支持上下左右四个方向。
///
/// 使用方式：
///
/// ```swift
/// let transitionDelegate = ModalSlideTransitionDelegate(
///     presentDirection: .fromRight,
///     dismissDirection: .fromLeft
/// )
///
/// viewController.modalPresentationStyle = .custom
/// viewController.transitioningDelegate = transitionDelegate
/// ```
///
/// - Important:
///   - 需持有该实例，否则转场期间代理对象可能被提前释放。
///   - 必须配合 `.custom` 模态展示样式使用。
public class ModalSlideTransitionDelegate: NSObject {
    
    public enum Direction {
        case fromLeft
        case fromRight
        case fromTop
        case fromBottom
    }
    
    private let presentDirection: Direction
    private let presentDuration: TimeInterval
    private let dismissDirection: Direction
    private let dismissDuration: TimeInterval
    
    public init(
        presentDirection: Direction = .fromRight,
        presentDuration: TimeInterval = 0.3,
        dismissDirection: Direction = .fromLeft,
        dismissDuration: TimeInterval = 0.3
    ) {
        self.presentDirection = presentDirection
        self.presentDuration = presentDuration
        self.dismissDirection = dismissDirection
        self.dismissDuration = dismissDuration
    }
    
}

extension ModalSlideTransitionDelegate: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(operation: .present, direction: presentDirection, duration: presentDuration)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(operation: .dismiss, direction: dismissDirection, duration: dismissDuration)
    }
    
}

fileprivate class Animator: NSObject {
    
    enum Operation {
        case present
        case dismiss
    }
    
    let operation: Operation
    let direction: ModalSlideTransitionDelegate.Direction
    let duration: TimeInterval
    
    init(operation: Operation, direction: ModalSlideTransitionDelegate.Direction, duration: TimeInterval) {
        self.operation = operation
        self.direction = direction
        self.duration = duration
    }
    
    private func presentingInitialFrame(finalFrame: CGRect) -> CGRect {
        switch direction {
        case .fromLeft:
            return finalFrame.offsetBy(
                dx: -finalFrame.width,
                dy: 0
            )
        case .fromRight:
            return finalFrame.offsetBy(
                dx: finalFrame.width,
                dy: 0
            )
        case .fromTop:
            return finalFrame.offsetBy(
                dx: 0,
                dy: -finalFrame.height
            )
        case .fromBottom:
            return finalFrame.offsetBy(
                dx: 0,
                dy: finalFrame.height
            )
        }
    }

    private func dismissingFinalFrame(currentFrame: CGRect) -> CGRect {
        switch direction {
        case .fromLeft:
            return currentFrame.offsetBy(
                dx: -currentFrame.width,
                dy: 0
            )
        case .fromRight:
            return currentFrame.offsetBy(
                dx: currentFrame.width,
                dy: 0
            )
        case .fromTop:
            return currentFrame.offsetBy(
                dx: 0,
                dy: -currentFrame.height
            )
        case .fromBottom:
            return currentFrame.offsetBy(
                dx: 0,
                dy: currentFrame.height
            )
        }
    }
    
}

extension Animator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            // 必须通知 UIKit 转场已经结束
            transitionContext.completeTransition(false)
            return
        }
        
        let fromView = transitionContext.view(forKey: .from) ?? fromVC.view!
        let toView = transitionContext.view(forKey: .to) ?? toVC.view!
        
        switch operation {
            
        case .present:
            
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let initialFrame = presentingInitialFrame(finalFrame: finalFrame)
            
            // Present 转场时 UIKit 尚未将 toView 加入容器视图，需要手动添加
            toView.frame = initialFrame
            transitionContext.containerView.addSubview(toView)
            
            UIView.animate(withDuration: duration) {
                toView.frame = finalFrame
            } completion: { _ in
                let completed = !transitionContext.transitionWasCancelled
                // 转场被取消时，将 toView 移出视图层级
                if !completed {
                    toView.removeFromSuperview()
                }
                // 必须通知 UIKit 转场已经结束
                transitionContext.completeTransition(completed)
            }
            
        case .dismiss:
            
            let currentFrame = fromView.frame
            let finalFrame = dismissingFinalFrame(currentFrame: currentFrame)
            
            UIView.animate(withDuration: duration) {
                fromView.frame = finalFrame
            } completion: { _ in
                let completed = !transitionContext.transitionWasCancelled
                // 转场被取消时，将 fromView 恢复到动画前的位置
                if !completed {
                    fromView.frame = currentFrame
                }
                // 必须通知 UIKit 转场已经结束
                transitionContext.completeTransition(completed)
            }
            
        }
    }
    
}
