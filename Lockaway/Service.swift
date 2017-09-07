//
//  Service.swift
//  Lockstep
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Foundation
import Starscream

fileprivate let secure = "s"
fileprivate let host = "jsonpipe.cyborch.com"
//fileprivate let host = "ws://localhost:3000"

class Service {
    
    var socket: WebSocket
    let delegate = SocketDelegate()
    let id: String
    var observer = LockObserver.shared()
    
    init(id: String) {
        self.id = id
        log.debug("Creating socket /pipe/\(id)")
        socket = WebSocket(url: URL(string: "ws\(secure)://\(host)/pipe/\(id)")!)
        socket.headers["Authorization"] = "Token v33gF7yxN6AUka1GjHhC15029130127920E2ZBAONga0PvMTquVkY"
        socket.delegate = delegate
    }
    
    func connect() {
        socket.connect()
    }
    
    func push() {
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        var request = URLRequest(url: URL(string: "http\(secure)://\(host)/push/\(id)")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Token v33gF7yxN6AUka1GjHhC15029130127920E2ZBAONga0PvMTquVkY",
            "Content-Length": "\(0)"
        ]
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                log.error("Error registering device token: \(error!)")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            guard statusCode < 300 else {
                log.error("Unexpected server response: \((response as! HTTPURLResponse).statusCode)")
                return
            }
            log.debug("Uploaded device token")
        }
        task.resume()
    }

}
