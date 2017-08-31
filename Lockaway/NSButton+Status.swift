//
//  NSButton+Status.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa

extension NSButton {
    enum Status: Int {
        case off = 0
        case on = 1
        case mixed = -1
    }
    
    var status: Status {
        get {
            return Status(rawValue: state)!
        }
    }
}
