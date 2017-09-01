//
//  BackgroundView.swift
//  Lockaway
//
//  Created by Anders Borch on 9/1/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa

class BackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(white: 0.93, alpha: 1).setFill()
        NSRectFill(dirtyRect);
        super.draw(dirtyRect)
    }
}
