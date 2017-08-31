//
//  PairView.swift
//  Lockstep
//
//  Created by Anders Borch on 8/14/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa

class PairView: NSView {
    @IBOutlet var controller: NSViewController?
    
    @IBOutlet var getButton: NSButton? {
        didSet {
//            guard let text = getButton?.title else { return }
//            let title = NSAttributedString(string: text,
//                                           attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle])
//            getButton?.attributedTitle = title
        }
    }
    
}
