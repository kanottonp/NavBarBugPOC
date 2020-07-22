//
//  SlideAnimatedTransitioning.swift
//  NavBarBugPOC
//
//  Created by Athipat Nampetch on 22/7/2563 BE.
//  Copyright © 2563 Athipat Nampetch. All rights reserved.
//

import UIKit

class SlideAnimatedTransitioning: NSObject {
    fileprivate var propertyAnimator: UIViewPropertyAnimator?
}

extension SlideAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // use animator to implement animateTransition
        
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }
        
        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        
        toView.frame = transitionContext.finalFrame(for: toViewController)
        toView.frame = CGRect(x: toView.frame.origin.x, y: toView.frame.origin.y, width: toView.frame.size.width, height: toView.frame.size.height + toView.frame.origin.y)

        let width = containerView.frame.width
        
        var offsetLeft = fromView.frame
        offsetLeft.origin.x = width
        
        var offscreenRight = toView.frame
        offscreenRight.origin.x = -width / 3.33;
        
        toView.frame = offscreenRight;
        
        toView.layer.opacity = 0.9
        
        containerView.insertSubview(toView, belowSubview: fromView)

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: UICubicTimingParameters(animationCurve: .easeInOut))
        
        animator.addAnimations {
            toView.frame = CGRect(x: fromView.frame.origin.x, y: toView.frame.origin.y, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = offsetLeft
            toView.layer.opacity = 1.0

        }
        
        animator.addCompletion { (success) in
            toView.layer.opacity = 1.0
            fromView.layer.opacity = 1.0
            fromViewController.navigationItem.titleView?.layer.opacity = 1

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
            self.propertyAnimator = nil

        }
        
        self.propertyAnimator = animator
        return animator
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if transitionContext?.transitionWasCancelled == true { return 0 }
        return 2
    }
    
}

