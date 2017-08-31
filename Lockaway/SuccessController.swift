//
//  SuccessController.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa

class SuccessController: NSViewController {
    @IBAction func ok(_ sender: Any) {
        self.view.window?.close()
    }
}
