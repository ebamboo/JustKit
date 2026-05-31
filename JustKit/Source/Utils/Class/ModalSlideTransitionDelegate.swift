//
//  Created by 姚旭 on 2021/11/28.
//

import UIKit

/// 模态滑动转场代理，支持上下左右四个方向
///
/// 赋值给 vc 的 `transitioningDelegate` 属性即可生效
/// 需持有该实例以保证其生命周期
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

private extension ModalSlideTransitionDelegate {
    
    class Animator: NSObject, UIViewControllerAnimatedTransitioning {
        
        // MARK: - Definition
        
        enum Operation {
            case present
            case dismiss
        }
        
        let operation: Operation
        let direction: Direction
        let duration: TimeInterval
        
        init(operation: Operation, direction: Direction, duration: TimeInterval) {
            self.operation = operation
            self.direction = direction
            self.duration = duration
        }
        
        // MARK: - Helper
        
        private func presentingInitialFrame(
            finalFrame: CGRect
        ) -> CGRect {
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

        private func dismissingFinalFrame(
            currentFrame: CGRect
        ) -> CGRect {
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
        
        // MARK: - UIViewControllerAnimatedTransitioning
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            // ================== animate begin =========================
            
            ///
            /// !!!!!!一定要理解视图层次!!!!!!
            /// UIViewController --> UIView --> Transition View --> Wrapper View
            /// UIWindowScene、UITabBarController、UINavigationController
            /// 除了以上三种控制器会生成 Transition View
            /// 模态时也会生成 Transition View，并且 Transition View 直接在 window 上
            /// presentedView 直接在 Transition View
            ///
            /// 做动画时注意 custom 和 fullScreen 的视图的层次结构
            /// 一般设置成 custom
            ///
            guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
            guard let toVC = transitionContext.viewController(forKey: .to) else { return }
            let fromView = transitionContext.view(forKey: .from) ?? fromVC.view!
            let toView = transitionContext.view(forKey: .to) ?? toVC.view!
            
            switch operation {
            case .present:
                let endFrame = transitionContext.initialFrame(for: fromVC)
                let beginFrame = presentingInitialFrame(finalFrame: endFrame)
                
                // 发生 present 转场时 toView 还没有在 containerView，需要添加 toView 到 containerView
                toView.frame = beginFrame
                transitionContext.containerView.addSubview(toView)
                UIView.animate(withDuration: duration) {
                    toView.frame = endFrame
                } completion: { finished in
                    // 上报转场结束并且是否成功情况，否则会认为还在转场 无法交互
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    if transitionContext.transitionWasCancelled {
                        // 取消时把要加入的 toView 移除
                        toView.removeFromSuperview()
                    }
                }
            case .dismiss:
                let currentFrame = transitionContext.initialFrame(for: fromVC)
                let endFrame = dismissingFinalFrame(currentFrame: currentFrame)
                
                UIView.animate(withDuration: duration) {
                    fromView.frame = endFrame
                } completion: { (finished) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
            
            // ================== animate end =========================
        }
        
    }
    
}
