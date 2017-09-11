//
//  ProximityManager.swift
//  Lockaway
//
//  Created by Anders Borch on 9/7/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import CoreBluetooth

class ProximityManager: NSObject, LockObserverDelegate {

    private func initializeManager() {
        proximityDelegate = ProximityDelegate()
        centralManager = CBCentralManager(delegate: self.proximityDelegate, queue: nil)
    }
    
    private var proximityDelegate: ProximityDelegate!
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        LockObserver.shared().observe(delegate: self)
    }
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

    // MARK: - LockObserverDelegate
    
    func lockedState(didChangeTo state: LockObserver.State) {
        switch state {
        case .locked:
            stopScan()
        case .unlocked:
            startScan()
        }
    }
}
