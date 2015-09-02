//
//  AFMPresentationAnimator.swift
//  Pods
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

public class AFMPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.7;
    }

    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)

        var finalFrame = transitionContext.initialFrameForViewController(fromViewController!)
        var initialFrame = CGRectOffset(finalFrame, 0, finalFrame.height)

        toViewController?.view.frame = initialFrame
        transitionContext.containerView().backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        transitionContext.containerView().addSubview(toViewController!.view)

        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.9,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { _ in
                transitionContext.containerView().backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
                toViewController?.view.frame = finalFrame
            }) { _ in
                transitionContext.completeTransition(true)
        }
    }
}