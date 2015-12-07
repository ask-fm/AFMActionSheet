//
//  ActionSheetViewController.swift
//  askfm
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

@IBDesignable
public class AFMActionSheetController: UIViewController {

    @IBInspectable public var controlHeight: Int        = 50 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var titleHeight: Int          = 50 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var spacing: Int              = 4  {
        didSet { self.updateUI() }
    }
    @IBInspectable public var horizontalMargin: Int     = 16 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var verticalMargin: Int       = 16 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var cornerRadius: Int         = 10 {
        didSet { self.updateUI() }
    }

    public private(set) var actions: [AFMAction] = []
    public private(set) var actionControls: [UIControl] = []
    public private(set) var cancelControls: [UIControl] = []
    public private(set) var titleView: UIView?

    private var actionControlConstraints: [NSLayoutConstraint] = []
    private var cancelControlConstraints: [NSLayoutConstraint] = []

    private var actionSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?

    private var actionGroupView: UIView = UIView()
    private var cancelGroupView: UIView = UIView()

    // MARK: Initializers

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupViews()
    }

    public init(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.setupViews()
        self.setupTranstioningDelegate(transitioningDelegate)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupViews() {
        self.view.addSubview(self.actionGroupView)
        self.view.addSubview(self.cancelGroupView)
        self.setupGroupViews()

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "recognizeGestures:")
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "recognizeGestures:")
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    public func setupTranstioningDelegate(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.modalPresentationStyle = .Custom
        self.actionSheetTransitioningDelegate = transitioningDelegate
        self.transitioningDelegate = self.actionSheetTransitioningDelegate
    }


    // MARK: Adding actions

    public func addAction(action: AFMAction) {
        let control = UIButton.controlWithAction(action)
        self.addAction(action, control: control)
    }

    public func addCancelAction(action: AFMAction) {
        let control = UIButton.controlWithAction(action)
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

        control.translatesAutoresizingMaskIntoConstraints = false
        if isCancelAction {
            self.cancelGroupView.addSubview(control)
            self.cancelGroupView.removeConstraints(self.cancelControlConstraints)
            self.cancelControlConstraints = self.constraintsForViews(self.cancelControls)
            self.cancelGroupView.addConstraints(self.cancelControlConstraints)
        } else {
            self.actionGroupView.addSubview(control)
            self.actionGroupView.removeConstraints(self.actionControlConstraints)
            self.actionControlConstraints = self.constraintsForViews(self.actionControlsWithTitle())
            self.actionGroupView.addConstraints(self.actionControlConstraints)
        }
    }

    public func addTitle(title: String) {
        let label = UILabel.titleWithText(title)
        self.addTitleView(label)
    }

    public func addTitleView(titleView: UIView) {
        self.titleView = titleView

        self.titleView!.translatesAutoresizingMaskIntoConstraints = false
        self.actionGroupView.addSubview(self.titleView!)
        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraintsForViews(self.actionControlsWithTitle())
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    private func actionControlsWithTitle() -> [UIView] {
        var views: [UIView] = self.actionControls
        if let titleView = self.titleView {
            views.append(titleView)
        }
        return views
    }


    // MARK: Control positioning

    private func setupGroupViews() {
        let setupGroupView: UIView -> Void = { groupView in
            groupView.clipsToBounds = true
            groupView.layer.cornerRadius = CGFloat(self.cornerRadius)
            groupView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[groupView]-margin-|",
                options: .DirectionLeadingToTrailing,
                metrics: ["margin": self.horizontalMargin],
                views: ["groupView": groupView]) 
            )
        }

        setupGroupView(self.actionGroupView)
        setupGroupView(self.cancelGroupView)

        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=margin)-[actionGroupView]-margin-[cancelGroupView]-margin-|",
            options: .DirectionLeadingToTrailing,
            metrics: ["margin": self.verticalMargin],
            views: ["actionGroupView": self.actionGroupView, "cancelGroupView": self.cancelGroupView]) 
        )
    }

    private func constraintsForViews(views: [UIView]) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []

        var sibling: UIView?
        for view in views {
            let isLast = view == views.last
            constraints.appendContentsOf(self.horizontalConstraintsForView(view))
            constraints.appendContentsOf(self.verticalConstraintsForView(view, isLast: isLast, sibling: sibling))

            sibling = view
        }
        
        return constraints
    }

    private func horizontalConstraintsForView(view: UIView) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|",
            options: .DirectionLeadingToTrailing,
            metrics: nil,
            views: ["view": view])
    }

    private func verticalConstraintsForView(view: UIView, isLast: Bool, sibling: UIView?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        var height = self.controlHeight
        if view == self.titleView {
            height = self.titleHeight
        }
        if let sibling = sibling {
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(height)]-spacing-[sibling]",
                options: .DirectionLeadingToTrailing,
                metrics: ["spacing": self.spacing, "height": height],
                views: ["view": view, "sibling": sibling]) )
        } else {
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[view(height)]-0-|",
                options: .DirectionLeadingToTrailing,
                metrics: ["height": height],
                views: ["view": view]) )
        }
        if isLast {
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]",
                options: .DirectionLeadingToTrailing,
                metrics: nil,
                views: ["view": view]) )
        }
        return constraints
    }

    private func updateUI() {
        self.view.removeConstraints(self.view.constraints)
        self.setupGroupViews()

        self.cancelGroupView.removeConstraints(self.cancelControlConstraints)
        self.cancelControlConstraints = self.constraintsForViews(self.cancelControls)
        self.cancelGroupView.addConstraints(self.cancelControlConstraints)
        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraintsForViews(self.actionControlsWithTitle())
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    func handleTaps(sender: UIControl) {
        let index = sender.tag
        let action = self.actions[index]
        if action.enabled {
            self.disableControls()
            self.dismissViewControllerAnimated(true, completion: { _ in
                self.enableControls()
                action.handler?(action)
            })
        }
    }

    func enableControls() {
        self.setUserInteractionOnControlsEnabled(true, controls: self.actionControls)
        self.setUserInteractionOnControlsEnabled(true, controls: self.cancelControls)
    }

    func disableControls() {
        self.setUserInteractionOnControlsEnabled(false, controls: self.actionControls)
        self.setUserInteractionOnControlsEnabled(false, controls: self.cancelControls)
    }

    func setUserInteractionOnControlsEnabled(enabled: Bool, controls: [UIControl]) {
        for control in controls {
            control.userInteractionEnabled = enabled
        }
    }

    func recognizeGestures(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(self.view)
        let view = self.view.hitTest(point, withEvent: nil)
        if (view == self.view) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}


// MARK: - Default control

extension UIButton {
    class func controlWithAction(action: AFMAction) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle(action.title, forState: .Normal)
        button.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        button.setTitleColor(UIColor.darkTextColor().colorWithAlphaComponent(0.5), forState: .Disabled)
        button.setTitleColor(UIColor.redColor(), forState: .Highlighted)

        return button
    }
}

extension UILabel {
    class func titleWithText(text: String) -> UILabel {
        let title = UILabel()
        title.text = text
        title.textAlignment = .Center
        title.backgroundColor = UIColor.whiteColor()

        return title
    }
}
