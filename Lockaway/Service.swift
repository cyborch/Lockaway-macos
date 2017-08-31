//
//  Service.swift
//  Lockstep
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import Starscream

class Service {
    
    var socket: WebSocket
    let delegate = SocketDelegate()
    let id: String
    var observer = LockObserver.shared()
    
    init(id: String) {
        self.id = id
        log.debug("Creating socket /pipe/\(id)")
        socket = WebSocket(url: URL(string: "wss://jsonpipe.cyborch.com/pipe/\(id)")!)
        socket.headers["Authorization"] = "Token v33gF7yxN6AUka1GjHhC15029130127920E2ZBAONga0PvMTquVkY"
        socket.delegate = delegate
    }
    
    func connect() {
        socket.connect()
    }
}
