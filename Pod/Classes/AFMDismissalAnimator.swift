//
//  AFMDismissalAnimator.swift
//  Pods
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit

open class AFMDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var animator: UIDynamicAnimator?

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as UIViewController

        let initialFrame = transitionContext.initialFrame(for: fromViewController)

        transitionContext.containerView.addSubview(fromViewController.view)

        let views = Array(fromViewController.view.subviews.reversed())
        let viewCount = Double(views.count)
        var index = 0

        let step: Double = self.transitionDuration(using: transitionContext) * 0.5 / viewCount
        for view in views {
            let delay = step * Double(index)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext) - delay,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    view.transform = CGAffineTransform(translationX: 0, y: initialFrame.height)
                }, completion: nil)
            index += 1
        }

        let backgroundColor = fromViewController.view.backgroundColor!

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
            animations: { 
                fromViewController.view.backgroundColor = backgroundColor.withAlphaComponent(0)
            }, completion: { _ in
                fromViewController.view.backgroundColor = backgroundColor
                transitionContext.completeTransition(true)
        }) 
    }
}
