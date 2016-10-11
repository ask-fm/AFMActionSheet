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

    @IBOutlet var titleView: UIView!

    @IBAction func buttonTapped(_ sender: AnyObject) {
        let actionSheet = AFMActionSheetController(style: .actionSheet, transitioningDelegate: AFMActionSheetTransitioningDelegate())

        let action1 = AFMAction(title: "Action 1", enabled: true) { (action: AFMAction) -> Void in
            print(action.title)
        }
        let action2 = AFMAction(title: "Action 2", enabled: false, handler: nil)
        let action3 = AFMAction(title: "Action 3", handler: nil)

        actionSheet.add(action1)
        actionSheet.add(action2)
        actionSheet.add(cancelling: action3)
        actionSheet.add(title: self.titleView)

        self.present(actionSheet, animated: true, completion: nil)
    }
}

