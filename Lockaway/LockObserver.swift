//
//  LockObserver.swift
//  Lockaway
//
//  Created by Anders Borch on 8/31/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import XCGLogger

fileprivate let observer = LockObserver()

protocol LockObserverDelegate: NSObjectProtocol {
    func lockedState(didChangeTo state: LockObserver.State)
}

class LockObserver {
    enum State {
        case locked, unlocked
    }

    
    private var observers = NSHashTable<AnyObject>.weakObjects()

    var state: State = .unlocked
    var lastUnlockTime = Date()
    
    fileprivate init() {
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
        log.debug("didLock")
        state = .locked
        for observer in observers.allObjects as! [LockObserverDelegate] {
            observer.lockedState(didChangeTo: state)
        }
        sendLockedState()
    }
    
    @objc func didUnlock(_ sender: Any) {
        log.debug("didUnlock")
        state = .unlocked
        lastUnlockTime = Date()
        for observer in observers.allObjects as! [LockObserverDelegate] {
            observer.lockedState(didChangeTo: state)
        }
        sendLockedState()
    }
    
    static func shared() -> LockObserver {
        return observer
    }
    
    func observe(delegate: LockObserverDelegate) {
        observers.add(delegate)
    }
    
    func sendLockedState() {
        let delegate = NSApplication.shared().delegate as! AppDelegate
        for service in delegate.services {
            if service.socket.isConnected {
                service.delegate.sendLockedState(socket: service.socket)
            }
        }
    }
}
