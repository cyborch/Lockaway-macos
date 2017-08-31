//
//  SocketDelegate.swift
//  Lockstep
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import Starscream
import XCGLogger
import LockMessage
import Gloss

class SocketDelegate: WebSocketDelegate {

    var observer = LockObserver.shared()
    let powerManager = PowerManager()
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocket) {
        let log = XCGLogger.default
        log.debug("websocketDidConnect")
        hello(socket: socket)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        let log = XCGLogger.default
        log.debug("websocketDidDisconnect")
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        let log = XCGLogger.default
        log.debug("websocketDidReceiveData: \(String(describing: String(data: data, encoding: .ascii)))")
        
        if (Message.from(data: data) as? LockMessage) != nil {
            startSaver()
        }
        
        if let message = Message.from(data: data) as? QueryMessage {
            respond(socket: socket, message: message)
        }
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let log = XCGLogger.default
        log.debug("websocketDidReceiveMessage")
    }

    // MARK: - Handlers
    
    func hello(socket: WebSocket) {
        let message = HelloMessage(role: .desktop)
        guard let data = message.toData() else {
            log.error("Could not serialize hello message")
            return
        }
        socket.write(data: data)
    }
    
    func sendLockedState(socket: WebSocket) {
        // convert LockObserver state to LockedStateMessage state
        let state: LockedStateMessage.State = observer.state == .locked ? .locked : .unlocked
        let response = LockedStateMessage(state: state)
        guard let data = response.toData() else {
            log.error("Could not serialize locked state message")
            return
        }
        socket.write(data: data)
    }
    
    func respond(socket: WebSocket, message: QueryMessage) {
        if message.query == .isLocked {
            sendLockedState(socket: socket)
        }
    }
    
    func startSaver() {
        // Use screensaver when available
        if !powerManager.startSaver() {
            // Use system sleep when screensaver isn't available
            powerManager.startSleep()
        }
    }
}
