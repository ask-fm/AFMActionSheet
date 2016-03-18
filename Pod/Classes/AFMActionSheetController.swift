//
//  ActionSheetViewController.swift
//  askfm
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit

@IBDesignable
public class AFMActionSheetController: UIViewController {

    public enum ControllerStyle : Int {
        case ActionSheet
        case Alert
    }

    @IBInspectable public var outsideGestureShouldDismiss: Bool = true

    @IBInspectable public var controlHeight: Int        = 50 {
        didSet { self.updateUI() }
    }
    @IBInspectable public var minTitleHeight: Int       = 50 {
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

    @IBInspectable public var spacingColor: UIColor = UIColor.clearColor() {
        didSet { self.updateUI() }
    }

    let controllerStyle: ControllerStyle

    public private(set) var actions: [AFMAction] = []
    public private(set) var actionControls: [UIControl] = []
    public private(set) var cancelControls: [UIControl] = []
    public private(set) var titleView: UIView?

    private var actionControlConstraints: [NSLayoutConstraint] = []
    private var cancelControlConstraints: [NSLayoutConstraint] = []

    private var actionSheetTransitioningDelegate: UIViewControllerTransitioningDelegate?

    var actionGroupView: UIView = UIView()
    var cancelGroupView: UIView = UIView()


    // MARK: Initializers

    public init(style: ControllerStyle) {
        self.controllerStyle = style
        super.init(nibName: nil, bundle: nil)
        self.setupViews()
    }

    public convenience init(style: ControllerStyle, transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.init(style: style)
        self.setupTranstioningDelegate(transitioningDelegate)
    }

    public convenience init(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.init(style: .ActionSheet, transitioningDelegate: transitioningDelegate)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.controllerStyle = .ActionSheet
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.controllerStyle = .ActionSheet
        super.init(coder: aDecoder)
        self.setupViews()
    }

    private func setupViews() {
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

        self.addControlToGroupView(control: control, isCancelAction: isCancelAction)
    }

    public func addTitle(title: String) {
        let label = UILabel.titleWithText(title)
        self.addTitleView(label)
    }

    public func addTitleView(titleView: UIView) {
        self.titleView = titleView

        self.titleView!.translatesAutoresizingMaskIntoConstraints = false
        self.actionGroupView.addSubview(self.titleView!)
        self.updateContraints()
    }


    private func addControlToGroupView(control control: UIControl, isCancelAction: Bool) {
        if self.controllerStyle == .ActionSheet {
            self.addControlToGroupViewForActionSheet(control: control, isCancelAction: isCancelAction)
        } else if self.controllerStyle == .Alert {
            self.addControlToGroupViewForAlert(control: control, isCancelAction: isCancelAction)
        }
    }

    private func addControlToGroupViewForActionSheet(control control: UIControl, isCancelAction: Bool) {
        control.translatesAutoresizingMaskIntoConstraints = false
        if isCancelAction {
            self.cancelGroupView.addSubview(control)
        } else {
            self.actionGroupView.addSubview(control)
        }
        self.updateContraints()
    }

    private func addControlToGroupViewForAlert(control control: UIControl, isCancelAction: Bool) {
        control.translatesAutoresizingMaskIntoConstraints = false
        self.actionGroupView.addSubview(control)
        self.updateContraints()
    }

    private func actionControlsWithTitle() -> [UIView] {
        var views: [UIView] = self.actionControls
        if let titleView = self.titleView {
            views.append(titleView)
        }
        return views
    }


    // MARK: Control positioning and updating

    func updateContraints() {
        if self.controllerStyle == .ActionSheet {
            self.updateContraintsForActionSheet()
        } else if self.controllerStyle == .Alert {
            self.updateContraintsForAlert()
        }
    }

    func updateContraintsForActionSheet() {
        self.cancelGroupView.removeConstraints(self.cancelControlConstraints)
        self.cancelControlConstraints = self.constraintsForViews(self.cancelControls)
        self.cancelGroupView.addConstraints(self.cancelControlConstraints)

        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraintsForViews(self.actionControlsWithTitle())
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    func updateContraintsForAlert() {
        var views: [UIView] = self.actionControlsWithTitle()
        let cancelViews: [UIView] = self.cancelControls
        views.insertContentsOf(cancelViews, at: 0)
        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraintsForViews(views)
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    private func setupGroupViews() {
        if self.controllerStyle == .ActionSheet {
            self.setupGroupViewsForActionSheet()
        } else if self.controllerStyle == .Alert {
            self.setupGroupViewsForAlert()
        }
        self.actionGroupView.backgroundColor = self.spacingColor
        self.cancelGroupView.backgroundColor = self.spacingColor
    }

    private func setupGroupViewsForActionSheet() {
        let setupGroupView: UIView -> Void = { groupView in
            groupView.removeFromSuperview()
            self.view.addSubview(groupView)
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

    private func setupGroupViewsForAlert() {
        self.actionGroupView.removeFromSuperview()
        self.view.addSubview(self.actionGroupView)

        self.actionGroupView.clipsToBounds = true
        self.actionGroupView.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.actionGroupView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[groupView]-margin-|",
            options: .DirectionLeadingToTrailing,
            metrics: ["margin": self.horizontalMargin],
            views: ["groupView": self.actionGroupView])
        )

        self.view.addConstraint(NSLayoutConstraint(item: self.actionGroupView,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0))
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
        let height = view != self.titleView ? self.controlHeight : self.minTitleHeight
        if let sibling = sibling {
            let format = view != self.titleView ? "V:[view(height)]-spacing-[sibling]" : "V:[view(>=height)]-spacing-[sibling]"
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(format,
                options: .DirectionLeadingToTrailing,
                metrics: ["spacing": self.spacing, "height": height],
                views: ["view": view, "sibling": sibling]) )
        } else {
            let format = view != self.titleView ? "V:[view(height)]-0-|" : "V:[view(>=height)]-0-|"
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(format,
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
        self.updateContraints()
    }


    // MARK: Event handling

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
        if (view == self.view && self.outsideGestureShouldDismiss) {
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
