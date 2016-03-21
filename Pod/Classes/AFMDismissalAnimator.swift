//
//  AFMDismissalAnimator.swift
//  Pods
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit

public class AFMDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var animator: UIDynamicAnimator?

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }

    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UIViewController!

        let initialFrame = transitionContext.initialFrameForViewController(fromViewController)
        transitionContext.containerView()!.addSubview(fromViewController.view)

        let views = Array(fromViewController.view.subviews.reverse())
        let viewCount = Double(views.count)
        var index = 0

        let step: Double = self.transitionDuration(transitionContext) * 0.5 / viewCount
        for view in views {
            let delay = step * Double(index)
            UIView.animateWithDuration(self.transitionDuration(transitionContext) - delay,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    view.transform = CGAffineTransformMakeTranslation(0, initialFrame.height)
                }, completion: nil)
            index++
        }

        let backgroundColor = fromViewController.view.backgroundColor!

        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: { _ in
                fromViewController.view.backgroundColor = backgroundColor.colorWithAlphaComponent(0)
            }) { _ in
                transitionContext.completeTransition(true)
        }
    }
}
