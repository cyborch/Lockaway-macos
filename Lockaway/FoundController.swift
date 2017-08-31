//
//  FoundController.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import CoreBluetooth

class FoundController: NSViewController {
    
    private let text = "A iPhone named “%@” was discovered nearby.\nDo you want to pair this phone and automatically\nlock your computer when it isn’t nearby?"

    @IBOutlet var delegate: FoundDelegate?
    @IBOutlet var question: NSTextField?
    @IBOutlet var noButton: NSButton?
    
    var central: CBCentralManager?
    
    var peripheral: CBPeripheral?
    
    func updateQuestion() {
        question?.stringValue = String(format: text, peripheral?.name ?? "iPhone")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateQuestion()
    }
    
    @IBAction func yes(_ sender: NSButton) {
        peripheral?.delegate = delegate
        central?.connect(peripheral!, options: nil)
        sender.title = "Connecting..."
        sender.isEnabled = false
    }
    
    @IBAction func no(_ sender: NSButton) {
        defer { self.dismiss(sender) }
        guard let peripheral = self.peripheral else { return }
        central?.cancelPeripheralConnection(peripheral)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let peripheral = self.peripheral else { return }
        central?.cancelPeripheralConnection(peripheral)
    }
}
