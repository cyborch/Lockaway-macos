//
//  PairController.swift
//  Lockstep
//
//  Created by Anders Borch on 8/12/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import CoreBluetooth

fileprivate let AppStoreURL = "https://magicmaclock.cyborch.com/iosapp"

class PairController: NSViewController {

    @IBOutlet var delegate: PairDelegate?
    @IBOutlet var scanButton: NSButton?
    
    private lazy var central: CBCentralManager = {
        let manager = CBCentralManager(delegate: self.delegate, queue: nil)
        return manager
    }()
    
    @IBAction func checkForDevices(_ button: NSButton) {
        switch button.status {
        case .on:
            button.title = "Checking..."
            delegate?.startScan(manager: central)
        case .off:
            button.title = "Check for devices"
            delegate?.stopScan(manager: central)
        case .mixed:
            // cannot happen
            break
        }
    }
    
    override func viewDidAppear() {
        log.debug("Initial central state: \(central.state.rawValue)")
    }
    
    override func viewDidDisappear() {
        log.debug("viewDidDisappear")
        delegate?.stopScan(manager: central)
    }
    
    @IBAction func openAppStoreUrl(_ sender: Any) {
        let url = URL(string: AppStoreURL)!
        NSWorkspace.shared().open(url)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let peripheral = sender as? CBPeripheral else { return }
        guard let controller = segue.destinationController as? FoundController else { return }
        controller.peripheral = peripheral
        controller.central = central
        scanButton?.state = NSOffState
        scanButton?.title = "Check for devices"
        delegate?.stopScan(manager: central)
    }
    
}

