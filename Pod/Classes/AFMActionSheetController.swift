//
//  ActionSheetViewController.swift
//  askfm
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

@IBDesignable
public class AFMActionSheetController: UIViewController {

    @IBInspectable public var controlHeight: Int   = 50 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var spacing: Int         = 4  {
        didSet { self.updateUI() }
    }
    @IBInspectable public var margin: Int          = 16 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var cornerRadius: Int    = 10 {
        didSet { self.updateUI() }
    }

    public private(set) var actions: [AFMAction] = []
    public private(set) var actionControls: [UIControl] = []
    public private(set) var cancelControls: [UIControl] = []

    private var actionControlConstraints: [NSLayoutConstraint] = []
    private var cancelControlConstraints: [NSLayoutConstraint] = []

    private var actionSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?

    private var actionGroupView: UIView = UIView()
    private var cancelGroupView: UIView = UIView()

    // MARK: Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view.addSubview(self.actionGroupView)
        self.view.addSubview(self.cancelGroupView)
        self.setupGroupViews()

        var swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "recognizeGestures:")
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "recognizeGestures:")
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)
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
            // when it comes to non cancel controls, we want to position them from top to bottom
            self.actionControls.insert(control, atIndex: 0)
        }

        control.setTranslatesAutoresizingMaskIntoConstraints(false)
        if isCancelAction {
            self.cancelGroupView.addSubview(control)
            self.cancelGroupView.removeConstraints(self.cancelControlConstraints)
            self.cancelControlConstraints = self.constraintsForControls(self.cancelControls)
            self.cancelGroupView.addConstraints(self.cancelControlConstraints)
        } else {
            self.actionGroupView.addSubview(control)
            self.actionGroupView.removeConstraints(self.actionControlConstraints)
            self.actionControlConstraints = self.constraintsForControls(self.actionControls)
            self.actionGroupView.addConstraints(self.actionControlConstraints)
        }
    }


    // MARK: Control positioning

    private func setupGroupViews() {
        let setupGroupView: UIView -> Void = { groupView in
            groupView.clipsToBounds = true
            groupView.layer.cornerRadius = CGFloat(self.cornerRadius)
            groupView.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[groupView]-margin-|",
                options: .DirectionLeadingToTrailing,
                metrics: ["margin": self.margin],
                views: ["groupView": groupView]) as! [NSLayoutConstraint]
            )
        }

        setupGroupView(self.actionGroupView)
        setupGroupView(self.cancelGroupView)

        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=margin)-[actionGroupView]-margin-[cancelGroupView]-margin-|",
            options: .DirectionLeadingToTrailing,
            metrics: ["margin": self.margin],
            views: ["actionGroupView": self.actionGroupView, "cancelGroupView": self.cancelGroupView]) as! [NSLayoutConstraint]
        )
    }

    private func constraintsForControls(controls: [UIControl]) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []

        var sibling: UIControl?
        for control in controls {
            var isLast = control == controls.last
            constraints.extend(self.horizontalConstraintsForControl(control))
            constraints.extend(self.verticalConstraintsForControl(control, isLast: isLast, sibling: sibling))

            sibling = control
        }
        
        return constraints
    }

    private func horizontalConstraintsForControl(control: UIControl) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[control]-0-|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["control": control]) as! [NSLayoutConstraint]
    }

    private func verticalConstraintsForControl(control: UIControl, isLast: Bool, sibling: UIControl?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let sibling = sibling {
            constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:[control(height)]-spacing-[sibling]",
                options: .DirectionLeadingToTrailing,
                metrics: ["spacing": self.spacing, "height": self.controlHeight],
                views: ["control": control, "sibling": sibling]) as! [NSLayoutConstraint])
        } else {
            constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:[control(height)]-0-|",
                options: .DirectionLeadingToTrailing,
                metrics: ["height": self.controlHeight],
                views: ["control": control]) as! [NSLayoutConstraint])
        }
        if isLast {
            constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[control(height)]",
                options: .DirectionLeadingToTrailing,
                metrics: ["height": self.controlHeight],
                views: ["control": control]) as! [NSLayoutConstraint])
        }
        return constraints
    }

    private func updateUI() {
        self.view.removeConstraints(self.view.constraints())
        self.setupGroupViews()

        self.cancelGroupView.removeConstraints(self.cancelControlConstraints)
        self.cancelControlConstraints = self.constraintsForControls(self.cancelControls)
        self.cancelGroupView.addConstraints(self.cancelControlConstraints)
        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraintsForControls(self.actionControls)
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    func handleTaps(sender: UIControl) {
        var index = sender.tag
        var action = self.actions[index]
        if action.enabled {
            self.dismissViewControllerAnimated(true, completion: { _ in action.handler?(action) })
        }
    }

    func recognizeGestures(gestureRecognizer: UIGestureRecognizer) {
        var point = gestureRecognizer.locationInView(self.view)
        var view = self.view.hitTest(point, withEvent: nil)
        if (view == self.view) {
            self.dismissViewControllerAnimated(true, completion: nil)
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
