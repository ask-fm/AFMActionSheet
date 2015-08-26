//
//  AFMDismissalAnimator.swift
//  Pods
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

public class AFMDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var animator: UIDynamicAnimator?

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }

    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)

        var initialFrame = transitionContext.initialFrameForViewController(fromViewController!)
        var finalFrame = CGRectMake(0, initialFrame.height, initialFrame.width, initialFrame.height)

        fromViewController?.view.frame = initialFrame
        transitionContext.containerView().backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        transitionContext.containerView().addSubview(fromViewController!.view)

        UIView.animateWithDuration(transitionDuration(transitionContext),
            animations: { _ in
                transitionContext.containerView().backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
                fromViewController?.view.frame = finalFrame
            }) { _ in
                transitionContext.completeTransition(true)
        }
    }
}
