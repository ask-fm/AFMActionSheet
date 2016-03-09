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

        let actionSheet = AFMActionSheetController(transitioningDelegate: AFMActionSheetTransitioningDelegate())

        let action1 = AFMAction(title: "Action 1", enabled: true) { (action: AFMAction) -> Void in
            print(action.title)
        }
        let action2 = AFMAction(title: "Action 2", enabled: false, handler: nil)
        let action3 = AFMAction(title: "Action 3", handler: nil)

        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addCancelAction(action3)

        self.presentViewController(actionSheet, animated: true, completion: nil)

    }
}

