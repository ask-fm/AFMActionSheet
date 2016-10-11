// https://github.com/Quick/Quick

import Quick
import Nimble
import Nimble_Snapshots
@testable import AFMActionSheet

class ActionSheetControllerSpec: QuickSpec {
    override func spec() {
        describe("created action sheet controller") {
            it("should have correct transition delegate, correct presentation style and controller style") {
                let controller = AFMActionSheetController(transitioningDelegate: AFMActionSheetTransitioningDelegate())
                expect(controller.transitioningDelegate).toNot(beNil())
                expect(controller.modalPresentationStyle).to(equal(UIModalPresentationStyle.custom))
                expect(controller.controllerStyle).to(equal(AFMActionSheetController.ControllerStyle.actionSheet))
            }

            it("should have gesture recognizers set up") {
                let controller = AFMActionSheetController()
                expect(controller.view.gestureRecognizers!.count).to(equal(2))
                expect(controller.view.gestureRecognizers!.first as? UISwipeGestureRecognizer).toNot(beNil())
                expect(controller.view.gestureRecognizers!.last as? UITapGestureRecognizer).toNot(beNil())
            }
        }

        describe("basic controller setup") {
            var controller: AFMActionSheetController!
            var action : AFMAction!

            beforeEach {
                controller = MockActionSheetController()
                action = AFMAction(title: "action", enabled: true, handler: nil)
            }

            it("should have correct number of actions and subviews when adding 1 action") {
                controller.add(action)
                expect(controller.actions.count).to(equal(1))
                expect(controller.actionControls.count).to(equal(1))
                expect(controller.actionGroupView.subviews.count).to(equal(1))
            }

            it("should have correct number of actions and subviews when adding 2 actions") {
                controller.add(action)
                controller.add(action)
                expect(controller.actions.count).to(equal(2))
                expect(controller.actionControls.count).to(equal(2))
                expect(controller.actionGroupView.subviews.count).to(equal(2))
            }

            it("should have correct number of actions and subviews when inserting an action") {
                controller.add(action)
                controller.add(action)
                let insertedControl = UIButton.control(with: action)
                controller.insert(action, with: insertedControl, at: 0)
                expect(controller.actions.count).to(equal(3))
                expect(controller.actionControls.count).to(equal(3))
                expect(controller.actionControls.first).to(equal(insertedControl))
                expect(controller.actionGroupView.subviews.count).to(equal(3))
            }

            it("should have correct number of actions and subviews when inserting an action at wrong position") {
                controller.add(action)
                controller.add(action)
                let insertedControl = UIButton.control(with: action)
                controller.insert(action, with: insertedControl, at: 42)
                expect(controller.actions.count).to(equal(2))
                expect(controller.actionControls.count).to(equal(2))
                expect(controller.actionControls.first).toNot(equal(insertedControl))
                expect(controller.actionGroupView.subviews.count).to(equal(2))
            }

            it("should have correct number of subviews when adding title view") {
                let titleView = UIView()
                controller.add(title: titleView)
                expect(controller.actionGroupView.subviews.count).to(equal(1))
            }

            it("should have label as title view view when adding title") {
                controller.add(titleLabelWith: "title")
                expect(controller.titleView as? UILabel).toNot(beNil())
                expect((controller.titleView as! UILabel).text).to(equal("title"))
                expect(controller.actionGroupView.subviews.count).to(equal(1))
            }

            it("should have control enabled if added action was enabled") {
                action.enabled = true
                controller.add(action)
                expect(controller.actionControls.first?.isEnabled).to(beTrue())
            }

            it("should have control disabled if added action was disabled") {
                action.enabled = false
                controller.add(action)
                expect(controller.actionControls.first?.isEnabled).to(beFalse())
            }

            it("should call correct action's handler when tapping on correspoding control") {
                var calledAction1 = false
                let action1 = AFMAction(title: "action1", enabled: true) { _ in
                    calledAction1 = true
                }
                var calledAction2 = false
                let action2 = AFMAction(title: "action2", enabled: true) { _ in
                    calledAction2 = true
                }
                controller.add(action1)
                controller.add(action2)
                controller.handleTaps(controller.actionControls.first!)
                expect(calledAction1).to(beTrue())
                expect(calledAction2).to(beFalse())
            }

            it("should not call action's handler if action was disabled") {
                var calledAction1 = false
                let action1 = AFMAction(title: "action1", enabled: false) { _ in
                    calledAction1 = true
                }
                controller.add(action1)
                controller.handleTaps(controller.actionControls.last!)
                expect(calledAction1).to(beFalse())
            }
        }

        describe("action sheet controller setup") {
            var controller: AFMActionSheetController!
            var action : AFMAction!

            beforeEach {
                controller = MockActionSheetController()
                action = AFMAction(title: "action", enabled: true, handler: nil)
            }

            it("should have set up action and cancel group views correctly") {
                expect(controller.actionGroupView.superview == controller.view).to(beTrue())
                expect(controller.cancelGroupView.superview == controller.view).to(beTrue())
            }

            it("should have correct number of actions and subviews when adding 1 cancel action") {
                controller.add(cancelling: action)
                expect(controller.actions.count).to(equal(1))
                expect(controller.cancelControls.count).to(equal(1))
                expect(controller.cancelGroupView.subviews.count).to(equal(1))
            }

            it("should have correct number of actions and subviews when adding different actions") {
                controller.add(action)
                controller.add(cancelling: action)
                controller.add(cancelling: action)
                controller.add(action)
                expect(controller.actions.count).to(equal(4))
                expect(controller.actionControls.count).to(equal(2))
                expect(controller.cancelControls.count).to(equal(2))
                expect(controller.actionGroupView.subviews.count).to(equal(2))
                expect(controller.cancelGroupView.subviews.count).to(equal(2))
            }
        }

        describe("alert controller setup") {
            var controller: AFMActionSheetController!
            var action : AFMAction!

            beforeEach {
                controller = MockActionSheetController(style: .alert)
                action = AFMAction(title: "action", enabled: true, handler: nil)
            }

            it("should have set up action and cancel group views correctly") {
                expect(controller.actionGroupView.superview == controller.view).to(beTrue())
                expect(controller.cancelGroupView.superview == nil).to(beTrue())
            }

            it("should have correct number of actions and subviews when adding 1 cancel action") {
                controller.add(cancelling: action)
                expect(controller.actions.count).to(equal(1))
                expect(controller.cancelControls.count).to(equal(1))
                expect(controller.cancelGroupView.subviews.count).to(equal(0))
            }

            it("should have correct number of actions and subviews when adding different actions") {
                controller.add(action)
                controller.add(cancelling: action)
                controller.add(cancelling: action)
                controller.add(action)
                expect(controller.actions.count).to(equal(4))
                expect(controller.actionControls.count).to(equal(2))
                expect(controller.cancelControls.count).to(equal(2))
                expect(controller.actionGroupView.subviews.count).to(equal(4))
                expect(controller.cancelGroupView.subviews.count).to(equal(0))
            }
        }

        describe("AFMActionSheetController", {
            it("has valid snapshot for action sheet setup") {
                let controller = AFMActionSheetController(style: .actionSheet, transitioningDelegate: AFMActionSheetTransitioningDelegate())
                self.setup(controller: controller)
                expect(controller.view).to(haveValidSnapshot(named: "AFMActionSheetController-ActionSheet-Snapshot"))
            }

            it("has valid snapshot for alert setup") {
                let controller = AFMActionSheetController(style: .alert, transitioningDelegate: AFMActionSheetTransitioningDelegate())
                self.setup(controller: controller)
                expect(controller.view).to(haveValidSnapshot(named: "AFMActionSheetController-Alert-Snapshot"))
            }
        });
    }

    func setup(controller: AFMActionSheetController) {
        let action1 = AFMAction(title: "Action 1", enabled: true, handler: nil)
        let action2 = AFMAction(title: "Action 2", enabled: false, handler: nil)
        let action3 = AFMAction(title: "Action 3", handler: nil)

        controller.add(action1)
        controller.add(action2)
        controller.add(cancelling: action3)
        controller.add(titleLabelWith: "Title")
    }

    class MockActionSheetController : AFMActionSheetController {
        override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
            completion?()
        }
    }
}
