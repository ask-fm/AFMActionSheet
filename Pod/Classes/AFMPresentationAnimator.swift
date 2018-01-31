//
//  AFMPresentationAnimator.swift
//  Pods
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit

open class AFMPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as UIViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as UIViewController

        let finalFrame = transitionContext.initialFrame(for: fromViewController)

        toViewController.view.frame = finalFrame

        transitionContext.containerView.addSubview(toViewController.view)

        let views = toViewController.view.subviews
        let viewCount = Double(views.count)
        var index = 0

        let step: Double = self.transitionDuration(using: transitionContext) * 0.5 / viewCount
        for view in views {
            view.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)

            let delay = step * Double(index)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext) - delay,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    view.transform = CGAffineTransform.identity;
                }, completion: nil)
            index += 1
        }

        let backgroundColor = toViewController.view.backgroundColor!
        toViewController.view.backgroundColor = backgroundColor.withAlphaComponent(0)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
            animations: { 
                toViewController.view.backgroundColor = backgroundColor
            }, completion: { _ in
                transitionContext.completeTransition(true)
        }) 
    }
}
