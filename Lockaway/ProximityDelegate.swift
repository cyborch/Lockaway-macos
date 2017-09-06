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
    
    private var timer: Timer {
        get {
            let timer = Timer(timeInterval: 1, repeats: true, block: { (timer) in
                self.detectWalkaway()
            })
            return timer
        }
    }
    
    private struct Discovery {
        var name: String
        var rssi: Int
        var time: Date
    }
    
    private var discovered: [String: Discovery] = [:]
    
    private func detectWalkaway() {
        for id in discovered.keys {
            guard let discovery = discovered[id] else { continue }
            log.verbose("Evaluating \(discovery) for walkaway")
            guard identifiers.contains(id) || names.contains(discovery.name) else { continue }
            if !identifiers.contains(id) { identifiers.append(id) }
            if names.contains(discovery.name) { names = names.filter { $0 != discovery.name } }
            if discovery.time.timeIntervalSince(Date()) < -5 || discovery.rssi < -90 {
                log.info("Starting screensaver")
                self.startSaver()
                return
            }
        }
    }
    
    func startSaver() {
        let delegate = NSApp.delegate as! AppDelegate
        delegate.startSaver()
    }
    
    func startScan(manager: CBCentralManager) {
        guard manager.state == .poweredOn else { return }
        log.debug("starting scanning")
        manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log.debug("state is: \(central.state.rawValue)")
        startScan(manager: central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name else { return }
        discovered[peripheral.identifier.uuidString] = Discovery(name: name, rssi: RSSI.intValue, time: Date())
    }
}
