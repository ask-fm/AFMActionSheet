// https://github.com/Quick/Quick

import Quick
import Nimble
import Nimble_Snapshots
import AFMActionSheet

class ActionSheetControllerSpec: QuickSpec {
    override func spec() {
        describe("creating action sheet controller") {
            it("should have transition delegate and correct presentation style") {
                var controller = AFMActionSheetController(transitioningDelegate: AFMActionSheetTransitioningDelegate())
                expect(controller.transitioningDelegate).toNot(beNil())
                expect(controller.modalPresentationStyle).to(equal(UIModalPresentationStyle.Custom))
            }
        }

        describe("adding actions to controller") {
            it("should have correct number of actions") {
                var controller = AFMActionSheetController()
                var action = AFMAction(title: "action", enabled: true, handler: nil)
                controller.addAction(action)
                expect(controller.view.subviews.count).to(equal(1))
                controller.addAction(action)
                expect(controller.view.subviews.count).to(equal(2))
                controller.addCancelAction(action)
                expect(controller.view.subviews.count).to(equal(3))

                // TODO: more sensible testing when @testable in swift 2 is available
            }
        }

        describe("AFMActionSheetController", {
            it("has valid snapshot") {
                var controller = AFMActionSheetController()
                var action = AFMAction(title: "action", enabled: true, handler: nil)
                controller.addAction(action)
                controller.addAction(action)
                controller.addCancelAction(action)

                expect(controller.view).to(haveValidSnapshot(named: "AFMActionSheetControllerSnapshot"))
            }
        });
    }
}
