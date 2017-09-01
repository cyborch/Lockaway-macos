//
//  SuccessController.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import ServiceManagement

fileprivate let HelperIdentifier = "com.cyborch.Lockaway.osx.helper" as CFString

class SuccessController: NSViewController {
    
    var auto = true
    
    override func viewDidAppear() {
        SMLoginItemSetEnabled(HelperIdentifier, true)
    }
    
    @IBAction func ok(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func toggle(_ sender: NSButton) {
        auto = !auto
        log.info("Setting auto startup to \(auto)")
        SMLoginItemSetEnabled(HelperIdentifier, auto)
    }
}
