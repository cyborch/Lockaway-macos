//
//  ProximityDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 9/5/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ProximityDelegate: NSObject, CBCentralManagerDelegate {

    private var names: [String] {
        get {
            let ud = UserDefaults.standard
            return ud.object(forKey: "Name") as? [String] ?? []
        }
        set(names) {
            let ud = UserDefaults.standard
            ud.set(names, forKey: "Name")
            ud.synchronize()
        }
    }
    
    private var identifiers: [String] {
        get {
            let ud = UserDefaults.standard
            return ud.object(forKey: "Peripheral") as? [String] ?? []
        }
        set(ids) {
            let ud = UserDefaults.standard
            ud.set(ids, forKey: "Peripheral")
            ud.synchronize()
        }
    }
    
    struct Discovery {
        var name: String
        var rssi: Int
        var time: Date
    }
    
    var discovered: [String: Discovery] = [:]

    var timer: Timer!
    
    private func initializeTimer() {
        timer = Timer(timeInterval: 1, repeats: true, block: { (timer) in
            self.detectWalkaway()
        })
    }
    

    func detectWalkaway() {
        for id in discovered.keys {
            guard let discovery = discovered[id] else { continue }
            log.verbose("Evaluating \(discovery) for walkaway")
            guard identifiers.contains(id) || names.contains(discovery.name) else { continue }
            if !identifiers.contains(id) { identifiers.append(id) }
            if names.contains(discovery.name) { names = names.filter { $0 != discovery.name } }
            let last = Date().timeIntervalSince(discovery.time)
            log.debug("Time since last discovery is \(last), rssi is \(discovery.rssi)")
            if last > 10 || discovery.rssi < -90 {
                log.debug("Time since last discovery is \(Date().timeIntervalSince(discovery.time)), rssi is \(discovery.rssi)")
                self.startSaver()
                return
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log.debug("state is: \(central.state.rawValue)")
        startScan(manager: central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name else { return }
        discovered[peripheral.identifier.uuidString] = Discovery(name: name, rssi: RSSI.intValue, time: Date())
        log.verbose("Discovered \(discovered[peripheral.identifier.uuidString]!)")
    }

    func startScan(manager: CBCentralManager) {
        guard manager.state == .poweredOn else { return }
        initializeTimer()
        log.debug("Starting scanning")
        manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
    }
    
    func stopScan() {
        timer.invalidate()
    }

    func startSaver() {
        let delegate = NSApp.delegate as! AppDelegate
        delegate.startSaver()
    }
}
