//
//  ActionSheetViewController.swift
//  askfm
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit

@IBDesignable
open class AFMActionSheetController: UIViewController {

    public enum ControllerStyle : Int {
        case actionSheet
        case alert
    }

    @IBInspectable open var outsideGestureShouldDismiss: Bool = true

    @IBInspectable open var minControlHeight: Int     = 50 {
        didSet { self.updateUI() }
    }
    @IBInspectable open var minTitleHeight: Int       = 50 {
        didSet { self.updateUI() }
    }
    @IBInspectable open var spacing: Int              = 4  {
        didSet { self.updateUI() }
    }
    @IBInspectable open var horizontalMargin: Int     = 16 {
        didSet { self.updateUI() }
    }
    @IBInspectable open var verticalMargin: Int       = 16 {
        didSet { self.updateUI() }
    }
    @IBInspectable open var cornerRadius: Int         = 10 {
        didSet { self.updateUI() }
    }

    @IBInspectable open var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5) {
        didSet { self.updateUI() }
    }

    @IBInspectable open var spacingColor: UIColor = UIColor.clear {
        didSet { self.updateUI() }
    }

    private var topMargin: Int {
        let statusBarHeight = Int(UIApplication.shared.statusBarFrame.height)
        return statusBarHeight > self.verticalMargin ? statusBarHeight : self.verticalMargin
    }

    open var dismissCompletionBlock: (() -> ())?

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

    public init(style: ControllerStyle, transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.controllerStyle = style
        super.init(nibName: nil, bundle: nil)
        self.setupViews()
        self.setup(transitioningDelegate)
    }

    public convenience init(style: ControllerStyle) {
        self.init(style: style, transitioningDelegate: AFMActionSheetTransitioningDelegate())
    }

    public convenience init(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.init(style: .actionSheet, transitioningDelegate: transitioningDelegate)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.controllerStyle = .actionSheet
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.setupViews()
        self.setup(AFMActionSheetTransitioningDelegate())
    }

    required public init?(coder aDecoder: NSCoder) {
        self.controllerStyle = .actionSheet
        super.init(coder: aDecoder)
        self.setupViews()
        self.setup(AFMActionSheetTransitioningDelegate())

    }

    private func setupViews() {
        self.setupGroupViews()
        self.setupGestureRecognizers()

        self.view.backgroundColor = self.backgroundColor
    }

    private func setupGestureRecognizers() {
        if let gestureRecognizers = self.view.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                self.view.removeGestureRecognizer(gestureRecognizer)
            }
        }

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AFMActionSheetController.recognizeGestures(_:)))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AFMActionSheetController.recognizeGestures(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false

        self.view.addGestureRecognizer(swipeGestureRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    open func setup(_ transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.modalPresentationStyle = .custom
        self.actionSheetTransitioningDelegate = transitioningDelegate
        self.transitioningDelegate = self.actionSheetTransitioningDelegate
    }


    // MARK: Adding actions

    private func setup(_ control: UIControl, with action: AFMAction) {
        control.isEnabled = action.enabled
        control.addTarget(self, action:#selector(AFMActionSheetController.handleTaps(_:)), for: .touchUpInside)
        control.tag = self.actions.count
    }

    open func add(_ action: AFMAction, with control: UIControl, andActionIsCancelling isCancellingAction: Bool) {
        self.setup(control, with: action)
        self.actions.append(action)

        if isCancellingAction {
            self.cancelControls.append(control)
        } else {
            self.actionControls.append(control)
        }

        self.addToGroupView(control, andActionIsCancelling: isCancellingAction)
    }

    open func insert(_ action: AFMAction, with control: UIControl, at position: Int, andActionIsCancelling isCancellingAction: Bool) {
        if isCancellingAction {
            guard position <= self.cancelControls.count else { return }
        } else {
            guard position <= self.actionControls.count else { return }
        }
        self.setup(control, with: action)
        self.actions.append(action)

        if isCancellingAction {
            self.cancelControls.insert(control, at: position)
        } else {
            self.actionControls.insert(control, at: position)
        }

        self.addToGroupView(control, andActionIsCancelling: isCancellingAction)
    }

    open func add(title: UIView) {
        self.titleView = title

        self.titleView!.translatesAutoresizingMaskIntoConstraints = false
        self.actionGroupView.addSubview(self.titleView!)
        self.updateContraints()
    }


    private func addToGroupView(_ control: UIControl, andActionIsCancelling isCancellingAction: Bool) {
        if self.controllerStyle == .actionSheet {
            self.addToGroupViewForActionSheet(control, andActionIsCancelling: isCancellingAction)
        } else if self.controllerStyle == .alert {
            self.addToGroupViewForAlert(control, andActionIsCancelling: isCancellingAction)
        }
    }

    private func addToGroupViewForActionSheet(_ control: UIControl, andActionIsCancelling isCancellingAction: Bool) {
        control.translatesAutoresizingMaskIntoConstraints = false
        if isCancellingAction {
            self.cancelGroupView.addSubview(control)
        } else {
            self.actionGroupView.addSubview(control)
        }
        self.updateContraints()
    }

    private func addToGroupViewForAlert(_ control: UIControl, andActionIsCancelling isCancellingAction: Bool) {
        control.translatesAutoresizingMaskIntoConstraints = false
        self.actionGroupView.addSubview(control)
        self.updateContraints()
    }

    private func actionControlsWithTitle() -> [UIView] {
        var views: [UIView] = self.actionControls
        if let titleView = self.titleView {
            views.insert(titleView, at: 0)
        }
        return views
    }


    // MARK: Control positioning and updating

    func updateContraints() {
        if self.controllerStyle == .actionSheet {
            self.updateContraintsForActionSheet()
        } else if self.controllerStyle == .alert {
            self.updateContraintsForAlert()
        }
    }

    func updateContraintsForActionSheet() {
        self.cancelGroupView.removeConstraints(self.cancelControlConstraints)
        self.cancelControlConstraints = self.constraints(for: self.cancelControls)
        self.cancelGroupView.addConstraints(self.cancelControlConstraints)

        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraints(for: self.actionControlsWithTitle())
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    func updateContraintsForAlert() {
        var views: [UIView] = self.actionControlsWithTitle()
        let cancelViews: [UIView] = self.cancelControls
        views.append(contentsOf: cancelViews)
        self.actionGroupView.removeConstraints(self.actionControlConstraints)
        self.actionControlConstraints = self.constraints(for: views)
        self.actionGroupView.addConstraints(self.actionControlConstraints)
    }

    private func setupGroupViews() {
        if self.controllerStyle == .actionSheet {
            self.setupGroupViewsForActionSheet()
        } else if self.controllerStyle == .alert {
            self.setupGroupViewsForAlert()
        }
        self.actionGroupView.backgroundColor = self.spacingColor
        self.cancelGroupView.backgroundColor = self.spacingColor
    }

    private func setupGroupViewsForActionSheet() {
        let setupGroupView: (UIView) -> Void = { groupView in
            groupView.removeFromSuperview()
            self.view.addSubview(groupView)
            groupView.clipsToBounds = true
            groupView.layer.cornerRadius = CGFloat(self.cornerRadius)
            groupView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[groupView]-margin-|",
                options: NSLayoutFormatOptions(),
                metrics: ["margin": self.horizontalMargin],
                views: ["groupView": groupView])
            )
        }

        setupGroupView(self.actionGroupView)
        setupGroupView(self.cancelGroupView)

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=topMargin)-[actionGroupView]-margin-[cancelGroupView]-margin-|",
            options: NSLayoutFormatOptions(),
            metrics: ["topMargin": self.topMargin, "margin": self.verticalMargin],
            views: ["actionGroupView": self.actionGroupView, "cancelGroupView": self.cancelGroupView])
        )
    }

    private func setupGroupViewsForAlert() {
        self.actionGroupView.removeFromSuperview()
        self.view.addSubview(self.actionGroupView)

        self.actionGroupView.clipsToBounds = true
        self.actionGroupView.layer.cornerRadius = CGFloat(self.cornerRadius)
        self.actionGroupView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[groupView]-margin-|",
            options: NSLayoutFormatOptions(),
            metrics: ["margin": self.horizontalMargin],
            views: ["groupView": self.actionGroupView])
        )

        self.view.addConstraint(NSLayoutConstraint(item: self.actionGroupView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[actionGroupView]-(>=margin)-|",
            options: NSLayoutFormatOptions(),
            metrics: ["margin": self.topMargin],
            views: ["actionGroupView": self.actionGroupView]))
    }

    private func constraints(for views: [UIView]) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []

        var sibling: UIView?
        // we want to position controls from top to bottom
        for view in views.reversed() {
            let isLast = view == views.first
            constraints.append(contentsOf: self.horizontalConstraints(for: view))
            constraints.append(contentsOf: self.verticalConstraints(for: view, withSibling: sibling, andIsLast: isLast))

            sibling = view
        }
        
        return constraints
    }

    private func horizontalConstraints(for view: UIView) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["view": view])
    }

    private func verticalConstraints(for view: UIView, withSibling sibling: UIView?, andIsLast isLast: Bool) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        let height = view != self.titleView ? self.minControlHeight : self.minTitleHeight
        if let sibling = sibling {
            let format = "V:[view(>=height)]-spacing-[sibling]"
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: format,
                options: NSLayoutFormatOptions(),
                metrics: ["spacing": self.spacing, "height": height],
                views: ["view": view, "sibling": sibling]) )
        } else {
            let format = "V:[view(>=height)]-0-|"
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: format,
                options: NSLayoutFormatOptions(),
                metrics: ["height": height],
                views: ["view": view]) )
        }
        if isLast {
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views: ["view": view]) )
        }
        return constraints
    }

    private func updateUI() {
        self.view.backgroundColor = self.backgroundColor
        self.view.removeConstraints(self.view.constraints)
        self.setupGroupViews()
        self.updateContraints()
    }


    // MARK: Event handling

    func handleTaps(_ sender: UIControl) {
        let index = sender.tag
        let action = self.actions[index]
        if action.enabled {
            self.disableControls()
            self.dismiss(animated: true, completion: { [unowned self] _ in
                self.enableControls()
                self.dismissCompletionBlock?()
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

    func setUserInteractionOnControlsEnabled(_ enabled: Bool, controls: [UIControl]) {
        for control in controls {
            control.isUserInteractionEnabled = enabled
        }
    }

    func recognizeGestures(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: self.view)
        let view = self.view.hitTest(point, with: nil)
        if (view == self.view && self.outsideGestureShouldDismiss) {
            self.disableControls()
            self.dismiss(animated: true, completion: { [unowned self] _ in
                self.enableControls()
                self.dismissCompletionBlock?()
            })
        }
    }
}


// MARK: - Helpers for adding views

extension AFMActionSheetController {

    open func add(_ action: AFMAction) {
        let control = UIButton.control(with: action)
        self.add(action, with: control)
    }

    open func add(cancelling action: AFMAction) {
        let control = UIButton.control(with: action)
        self.add(cancelling: action, with: control)
    }

    open func add(_ action: AFMAction, with control: UIControl) {
        self.add(action, with: control, andActionIsCancelling: false)
    }

    open func add(cancelling action: AFMAction, with control: UIControl) {
        self.add(action, with: control, andActionIsCancelling: true)
    }

    open func insert(_ action: AFMAction, at position: Int) {
        let control = UIButton.control(with: action)
        self.insert(action, with: control, at: position)
    }

    open func insert(cancelling action: AFMAction, at position: Int) {
        let control = UIButton.control(with: action)
        self.insert(cancelling: action, with: control, at: position)
    }

    open func insert(_ action: AFMAction, with control: UIControl, at position: Int) {
        self.insert(action, with: control, at: position, andActionIsCancelling: false)
    }

    open func insert(cancelling action: AFMAction, with control: UIControl, at position: Int) {
        self.insert(action, with: control, at: position, andActionIsCancelling: true)
    }

    open func add(titleLabelWith text: String) {
        let label = UILabel.title(with: text)
        self.add(title: label)
    }
}


// MARK: - Default control

extension UIButton {
    class func control(with action: AFMAction) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.setTitle(action.title, for: UIControlState())
        button.setTitleColor(UIColor.darkText, for: UIControlState())
        button.setTitleColor(UIColor.darkText.withAlphaComponent(0.5), for: .disabled)
        button.setTitleColor(UIColor.red, for: .highlighted)

        return button
    }
}

extension UILabel {
    class func title(with text: String) -> UILabel {
        let title = UILabel()
        title.text = text
        title.textAlignment = .center
        title.backgroundColor = UIColor.white

        return title
    }
}
