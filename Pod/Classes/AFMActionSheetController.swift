//
//  ActionSheetViewController.swift
//  askfm
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

@IBDesignable
public class AFMActionSheetController: UIViewController {

    @IBInspectable var controlHeight: Int   = 50
    @IBInspectable var spacing: Int         = 4
    @IBInspectable var margin: Int          = 16
    @IBInspectable var cornerRadius: Int    = 10

    var actions: [AFMAction] = []
    var actionControls: [UIControl] = []
    var cancelControls: [UIControl] = []
    private var actionControlConstraints: [NSLayoutConstraint] = []

    private var actionSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?


    // MARK: Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .Custom
        self.actionSheetTransitioningDelegate = transitioningDelegate
        self.transitioningDelegate = self.actionSheetTransitioningDelegate
    }

    public convenience init(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.init(nibName: nil, bundle: nil, transitioningDelegate: transitioningDelegate)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    // MARK: Adding actions

    public func addAction(action: AFMAction) {
        var control = UIButton.controlWithAction(action)
        self.addAction(action, control: control)
    }

    public func addCancelAction(action: AFMAction) {
        var control = UIButton.controlWithAction(action)
        self.addCancelAction(action, control: control)
    }

    public func addAction(action: AFMAction, control: UIControl) {
        self.addAction(action, control: control, isCancelAction: false)
    }

    public func addCancelAction(action: AFMAction, control: UIControl) {
        self.addAction(action, control: control, isCancelAction: true)
    }

    func addAction(action: AFMAction, control: UIControl, isCancelAction: Bool) {
        control.enabled = action.enabled
        control.addTarget(self, action:"handleTaps:", forControlEvents: .TouchUpInside)
        control.tag = self.actions.count

        self.actions.append(action)
        if isCancelAction {
            self.cancelControls.append(control)
        } else {
            self.actionControls.append(control)
        }

        control.layer.cornerRadius = CGFloat(self.cornerRadius)
        control.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(control)
        self.configureSubviewGeometry()
    }


    // MARK: Control positioning

    private func configureSubviewGeometry() {
        self.view.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints.removeAll(keepCapacity: true)
        self.actionControlConstraints = self.constraintsForControls()
        self.view.addConstraints(self.actionControlConstraints)
    }

    private func constraintsForControls() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []

        var controls = self.cancelControls
        controls.extend(self.actionControls.reverse()) // when it comes to non cancel controls, we want to position them from top to bottom

        var sibling: UIControl?
        for control in controls {
            constraints.extend(self.horizontalConstraintsForControl(control))
            constraints.extend(self.verticalConstraintsForControl(control, sibling: sibling))

            sibling = control
        }
        
        return constraints
    }

    private func horizontalConstraintsForControl(control: UIControl) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[control]-margin-|",
            options: .DirectionLeadingToTrailing,
            metrics: ["margin": self.margin],
            views: ["control": control]) as! [NSLayoutConstraint]
    }

    private func verticalConstraintsForControl(control: UIControl, sibling: UIControl?) -> [NSLayoutConstraint] {
        if let sibling = sibling {
            var spacing = self.spacing
            if !contains(self.cancelControls, control) && contains(self.cancelControls, sibling) {
                spacing = margin
            }
            return NSLayoutConstraint.constraintsWithVisualFormat("V:[control(height)]-spacing-[sibling]",
                options: .DirectionLeadingToTrailing,
                metrics: ["spacing": spacing, "height": self.controlHeight],
                views: ["control": control, "sibling": sibling]) as! [NSLayoutConstraint]
        } else {
            return NSLayoutConstraint.constraintsWithVisualFormat("V:[control(height)]-margin-|",
                options: .DirectionLeadingToTrailing,
                metrics: ["margin": self.margin, "height": self.controlHeight],
                views: ["control": control]) as! [NSLayoutConstraint]
        }
    }

    func handleTaps(sender: UIControl) {
        var index = sender.tag
        var action = self.actions[index]
        if action.enabled {
            self.dismissViewControllerAnimated(true, completion: { _ in action.handler?(action) })
        }
    }
}


// MARK: - Default control

extension UIButton {
    class func controlWithAction(action: AFMAction) -> UIButton {
        var button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle(action.title, forState: .Normal)
        button.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        button.setTitleColor(UIColor.darkTextColor().colorWithAlphaComponent(0.5), forState: .Disabled)
        button.setTitleColor(UIColor.redColor(), forState: .Highlighted)

        return button
    }
}
