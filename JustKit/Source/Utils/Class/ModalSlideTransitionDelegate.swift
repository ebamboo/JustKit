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
///     presentDirection: .toLeft,
///     dismissDirection: .toRight
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
        case toRight
        case toLeft
        case toBottom
        case toTop
    }
    
    private let presentDirection: Direction
    private let presentDuration: TimeInterval
    private let dismissDirection: Direction
    private let dismissDuration: TimeInterval
    
    public init(
        presentDirection: Direction = .toLeft,
        presentDuration: TimeInterval = 0.3,
        dismissDirection: Direction = .toRight,
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
        case .toRight:
            return finalFrame.offsetBy(
                dx: -finalFrame.width,
                dy: 0
            )
        case .toLeft:
            return finalFrame.offsetBy(
                dx: finalFrame.width,
                dy: 0
            )
        case .toBottom:
            return finalFrame.offsetBy(
                dx: 0,
                dy: -finalFrame.height
            )
        case .toTop:
            return finalFrame.offsetBy(
                dx: 0,
                dy: finalFrame.height
            )
        }
    }

    private func dismissingFinalFrame(currentFrame: CGRect) -> CGRect {
        switch direction {
        case .toRight:
            return currentFrame.offsetBy(
                dx: currentFrame.width,
                dy: 0
            )
        case .toLeft:
            return currentFrame.offsetBy(
                dx: -currentFrame.width,
                dy: 0
            )
        case .toBottom:
            return currentFrame.offsetBy(
                dx: 0,
                dy: currentFrame.height
            )
        case .toTop:
            return currentFrame.offsetBy(
                dx: 0,
                dy: -currentFrame.height
            )
        }
    }
    
}

extension Animator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 获取参与转场的控制器及对应视图
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let fromView = transitionContext.view(forKey: .from) ?? fromVC.view!
        let toView = transitionContext.view(forKey: .to) ?? toVC.view!
        
        switch operation {
            
        case .present:
            
            // presented 控制器最终应处于的位置
            let finalFrame = transitionContext.finalFrame(for: toVC)
            
            // 根据转场方向计算动画起始位置
            let initialFrame = presentingInitialFrame(finalFrame: finalFrame)
            
            // Present 转场时 UIKit 尚未将 toView 加入容器视图，需要手动添加
            toView.frame = initialFrame
            transitionContext.containerView.addSubview(toView)
            
            UIView.animate(withDuration: duration) {
                toView.frame = finalFrame
            } completion: { _ in
                let completed = !transitionContext.transitionWasCancelled
                // 转场被取消时，需要恢复视图层级
                if !completed {
                    toView.removeFromSuperview()
                }
                // 必须通知 UIKit 转场已经结束
                transitionContext.completeTransition(completed)
            }
            
        case .dismiss:
            
            // 当前展示位置作为动画起点
            let currentFrame = fromView.frame
            
            // 根据转场方向计算移出屏幕后的目标位置
            let finalFrame = dismissingFinalFrame(currentFrame: currentFrame)
            
            UIView.animate(withDuration: duration) {
                fromView.frame = finalFrame
            } completion: { _ in
                // 必须通知 UIKit 转场已经结束
                transitionContext.completeTransition(
                    !transitionContext.transitionWasCancelled
                )
            }
            
        }
    }
    
}
