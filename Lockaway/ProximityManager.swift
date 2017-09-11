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
    private var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override init() {
        super.init()
        LockObserver.shared().observe(delegate: self)
    }

    private func setOperation(after deadline: DispatchTime, _ block: @escaping () -> Void) {
        queue.isSuspended = true
        queue.cancelAllOperations()
        queue.addOperation(block)
        DispatchQueue.main.asyncAfter(deadline: deadline) { 
            self.queue.isSuspended = false
        }
    }
    
    func stopScan() {
        queue.cancelAllOperations()
        centralManager.stopScan()
        centralManager.delegate = nil
        proximityDelegate.stopScan()
    }
    
    func startScan() {
        initializeManager()
        proximityDelegate.startScan(manager: centralManager)
        setOperation(after: .now() + .seconds(9)) {
            log.debug("Testing if discoveries are valid.")
            self.queue.cancelAllOperations()
            DispatchQueue.main.sync {
                /*
                 Restart scanning if no new devices were discovered after 9 seconds.
                 This could be an indication that the BLE stack is broken somewhow.
                 */
                guard LockObserver.shared().state == .unlocked else { return }
                guard !self.proximityDelegate.discoveriesAreValid() else { return }
                log.warning("No new devices were discovered since scanning started. Restarting scanning.")
                self.stopScan()
                self.startScan()
            }
        }
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
