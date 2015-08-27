//
//  ViewController.swift
//  AFMActionSheet
//
//  Created by Ilya Alesker on 08/26/2015.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

import UIKit
import AFMActionSheet

class ViewController: UIViewController {

    @IBAction func buttonTapped(sender: AnyObject) {

        var actionSheet = AFMActionSheetController(transitioningDelegate: AFMActionSheetTransitioningDelegate())

        var action1 = AFMAction(title: "Action 1", enabled: true) { (action: AFMAction) -> Void in
            println(action.title)
        }
        var action2 = AFMAction(title: "Action 2", enabled: false, handler: nil)
        var action3 = AFMAction(title: "Action 3", handler: nil)

        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addCancelAction(action3)

        self.presentViewController(actionSheet, animated: true, completion: nil)

    }
}

