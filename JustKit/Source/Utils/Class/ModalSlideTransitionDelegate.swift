//
//  Created by 姚旭 on 2021/11/28.
//

import UIKit

/// 模态滑动转场代理。
///
/// 为模态展示（Present）和关闭（Dismiss）提供滑动转场动画，
/// 支持上下左右四个方向。
///
/// 典型用法 — 在被展示的控制器中持有并配置：
///
/// ```swift
/// class PresentedViewController: UIViewController {
///
///     let transition = ModalSlideTransitionDelegate(
///         presentConfiguration: .init(direction: .left),
///         dismissConfiguration: .init(direction: .right)
///     )
///
///     override init(nibName: String?, bundle: Bundle?) {
///         super.init(nibName: nibName, bundle: bundle)
///         transitioningDelegate = transition
///         modalPresentationStyle = .custom
///     }
///
/// }
/// ```
///
/// - Important:
///   - 需持有该实例，否则转场期间代理对象可能被提前释放。
///   - 必须配合 `.custom` 模态展示样式使用。
public class ModalSlideTransitionDelegate: NSObject {
    
    public struct Configuration {
        
        public enum Direction {
            case left
            case right
            case top
            case bottom
        }
        
        public let direction: Direction
        public let duration: TimeInterval
        public let animationOptions: UIView.AnimationOptions
        
        public init(
            direction: Direction,
            duration: TimeInterval = 0.35,
            animationOptions: UIView.AnimationOptions = .curveEaseOut
        ) {
            self.direction = direction
            self.duration = duration
            self.animationOptions = animationOptions
        }
        
    }
    
    public let presentConfiguration: Configuration
    public let dismissConfiguration: Configuration
    
    public init(
        presentConfiguration: Configuration = .init(direction: .left),
        dismissConfiguration: Configuration = .init(direction: .right)
    ) {
        self.presentConfiguration = presentConfiguration
        self.dismissConfiguration = dismissConfiguration
    }
    
}

extension ModalSlideTransitionDelegate: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(operation: .present, configuration: presentConfiguration)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(operation: .dismiss, configuration: dismissConfiguration)
    }
    
}

private class Animator: NSObject {
    
    enum Operation {
        case present
        case dismiss
    }
    
    let operation: Operation
    let configuration: ModalSlideTransitionDelegate.Configuration
    
    init(
        operation: Operation,
        configuration: ModalSlideTransitionDelegate.Configuration
    ) {
        self.operation = operation
        self.configuration = configuration
    }
    
    func presentingInitialFrame(finalFrame: CGRect) -> CGRect {
        switch configuration.direction {
        case .left:
            return finalFrame.offsetBy(
                dx: finalFrame.width,
                dy: 0
            )
        case .right:
            return finalFrame.offsetBy(
                dx: -finalFrame.width,
                dy: 0
            )
        case .top:
            return finalFrame.offsetBy(
                dx: 0,
                dy: finalFrame.height
            )
        case .bottom:
            return finalFrame.offsetBy(
                dx: 0,
                dy: -finalFrame.height
            )
        }
    }

    func dismissingFinalFrame(currentFrame: CGRect) -> CGRect {
        switch configuration.direction {
        case .left:
            return currentFrame.offsetBy(
                dx: -currentFrame.width,
                dy: 0
            )
        case .right:
            return currentFrame.offsetBy(
                dx: currentFrame.width,
                dy: 0
            )
        case .top:
            return currentFrame.offsetBy(
                dx: 0,
                dy: -currentFrame.height
            )
        case .bottom:
            return currentFrame.offsetBy(
                dx: 0,
                dy: currentFrame.height
            )
        }
    }
    
}

extension Animator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return configuration.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // ----------------------------------------
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
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
            
            UIView.animate(withDuration: configuration.duration, delay: 0, options: configuration.animationOptions) {
                toView.frame = finalFrame
            } completion: { _ in
                let completed = !transitionContext.transitionWasCancelled
                // 转场被取消时，将 toView 移出视图层级
                if !completed {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(completed)
            }
            
        case .dismiss:
            
            let currentFrame = fromView.frame
            let finalFrame = dismissingFinalFrame(currentFrame: currentFrame)
            
            UIView.animate(withDuration: configuration.duration, delay: 0, options: configuration.animationOptions) {
                fromView.frame = finalFrame
            } completion: { _ in
                let completed = !transitionContext.transitionWasCancelled
                // 转场被取消时，将 fromView 恢复到动画前的位置
                if !completed {
                    fromView.frame = currentFrame
                }
                transitionContext.completeTransition(completed)
            }
            
        }
        // ----------------------------------------
    }
    
}
