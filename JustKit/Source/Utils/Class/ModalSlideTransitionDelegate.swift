//
//  Created by 姚旭 on 2021/11/28.
//

import UIKit

///
/// 自定义模态动画
/// 目前仅支持四个方向的动画
/// 只需要把需要自定义模态动画的 vc 的属性 transitioningDelegate
/// 设置为 ModalSlideTransitionDelegate 实例即可
/// 注意 ModalSlideTransitionDelegate 实例的生命周期
///


// MARK: - 自定义模态转场

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

// MARK: - 转场实现

extension ModalSlideTransitionDelegate: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(operation: .present, direction: presentDirection, duration: presentDuration)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(operation: .dismiss, direction: dismissDirection, duration: dismissDuration)
    }
    
}

// MARK: - 动画实现

private extension ModalSlideTransitionDelegate {
    
    
    
    class Animator: NSObject, UIViewControllerAnimatedTransitioning {
        
        enum Operation {
            case present
            case dismiss
        }
        
        let operation: Operation
        let direction: Direction
        let duration: TimeInterval
        
        init(operation: Operation, direction: ModalSlideTransitionDelegate.Direction, duration: TimeInterval = 0.4) {
            self.operation = operation
            self.direction = direction
            self.duration = duration
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
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
                let containerFrame = transitionContext.initialFrame(for: fromVC)
                let beginFrame: CGRect!
                switch direction {
                case .toRight:
                    beginFrame = containerFrame.offsetBy(dx: -containerFrame.size.width, dy: 0)
                case .toLeft:
                    beginFrame = containerFrame.offsetBy(dx: containerFrame.size.width, dy: 0)
                case .toBottom:
                    beginFrame = containerFrame.offsetBy(dx: 0, dy: -containerFrame.size.height)
                case .toTop:
                    beginFrame = containerFrame.offsetBy(dx: 0, dy: containerFrame.size.height)
                }
                let endFrame = containerFrame
                
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
                let containerFrame = transitionContext.initialFrame(for: fromVC)
                let endFrame: CGRect!
                switch direction {
                case .toRight:
                    endFrame = containerFrame.offsetBy(dx: containerFrame.size.width, dy: 0)
                case .toLeft:
                    endFrame = containerFrame.offsetBy(dx: -containerFrame.size.width, dy: 0)
                case .toBottom:
                    endFrame = containerFrame.offsetBy(dx: 0, dy: containerFrame.size.height)
                case .toTop:
                    endFrame = containerFrame.offsetBy(dx: 0, dy: -containerFrame.size.height)
                }
                
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
                    fromView.frame = endFrame
                } completion: { (finished) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
        
    }

}
