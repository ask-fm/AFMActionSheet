//
//  Action.swift
//  askfm
//
//  Created by Ilya Alesker on 26/08/15.
//  Copyright (c) 2015 Ask.fm Europe, Ltd. All rights reserved.
//

@objc
public class AFMAction: NSObject {

    public var title: String = ""
    public var enabled: Bool = true
    public var handler: ((AFMAction) -> Void)?

    public init(title: String, enabled: Bool, handler: ((AFMAction) -> Void)?) {
        self.title = title
        self.enabled = enabled
        self.handler = handler
    }

    public convenience init(title: String, handler: ((AFMAction) -> Void)?) {
        self.init(title: title, enabled: true, handler: handler)
    }
}