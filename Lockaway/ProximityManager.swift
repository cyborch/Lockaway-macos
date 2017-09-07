//
//  ProximityManager.swift
//  Lockaway
//
//  Created by Anders Borch on 9/7/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import CoreBluetooth

class ProximityManager {

    private func initializeManager() {
        proximityDelegate = ProximityDelegate()
        centralManager = CBCentralManager(delegate: self.proximityDelegate, queue: nil)
    }
    
    private var proximityDelegate: ProximityDelegate!
    private var centralManager: CBCentralManager!
    
    init() {
        DistributedNotificationCenter.default().addObserver(self,
                                                            selector: #selector(didLock(_:)),
                                                            name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"),
                                                            object: nil)
        DistributedNotificationCenter.default().addObserver(self,
                                                            selector: #selector(didUnlock(_:)),
                                                            name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"),
                                                            object: nil)
    }
    
    @objc func didLock(_ sender: Any) {
        log.debug("Stopping scan on sleep")
        stopScan()
    }
    
    @objc func didUnlock(_ sender: Any) {
        log.debug("Restarting scan after unlock")
        startScan()
    }

    func stopScan() {
        centralManager.stopScan()
        centralManager.delegate = nil
        proximityDelegate.stopScan()
    }
    
    func startScan() {
        initializeManager()
        proximityDelegate.startScan(manager: centralManager)
    }
    
}
