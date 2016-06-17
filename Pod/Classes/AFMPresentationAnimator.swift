//
//  AFMPresentationAnimator.swift
//  Pods
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit

public class AFMPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }

    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as UIViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as UIViewController

        let finalFrame = transitionContext.initialFrameForViewController(fromViewController)

        toViewController.view.frame = finalFrame

        #if swift(>=2.3)
            transitionContext.containerView().addSubview(toViewController.view)
        #else
            transitionContext.containerView()!.addSubview(toViewController.view)
        #endif

        let views = toViewController.view.subviews
        let viewCount = Double(views.count)
        var index = 0

        let step: Double = self.transitionDuration(transitionContext) * 0.5 / viewCount
        for view in views {
            view.transform = CGAffineTransformMakeTranslation(0, finalFrame.height)

            let delay = step * Double(index)
            UIView.animateWithDuration(self.transitionDuration(transitionContext) - delay,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    view.transform = CGAffineTransformIdentity;
                }, completion: nil)
            index += 1
        }

        let backgroundColor = toViewController.view.backgroundColor!
        toViewController.view.backgroundColor = backgroundColor.colorWithAlphaComponent(0)

        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: { _ in
                toViewController.view.backgroundColor = backgroundColor
            }) { _ in
                transitionContext.completeTransition(true)
        }
    }
}
