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

class LockObserver {
    enum State {
        case locked, unlocked
    }
    
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
        sendLockedState()
    }
    
    @objc func didUnlock(_ sender: Any) {
        log.debug("didUnlock")
        state = .unlocked
        lastUnlockTime = Date()
        sendLockedState()
    }
    
    static func shared() -> LockObserver {
        return observer
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
