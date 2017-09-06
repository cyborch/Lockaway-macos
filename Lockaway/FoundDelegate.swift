//
//  FoundDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import CoreBluetooth

let SocketIDCharacteristic = CBUUID(string: "0E486070-4BDB-4902-9F78-C037F80B8577")
let NameCharacteristic = CBUUID(string: "F021A685-9BC6-491B-A3DC-0816F0026F57")

class FoundDelegate: NSObject, CBPeripheralDelegate {
    
    @IBOutlet var controller: NSViewController?
    private var characteristicCount = 0
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        for service in peripheral.services ?? [] {
            guard service.uuid == ConfigurationService else { continue }
            peripheral.discoverCharacteristics([SocketIDCharacteristic, NameCharacteristic], for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard service.uuid == ConfigurationService else { return }
        characteristicCount = 0
        for characteristic in service.characteristics ?? [] {
            guard characteristic.uuid == SocketIDCharacteristic || characteristic.uuid == NameCharacteristic else { continue }
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else { return }
        guard let data = characteristic.value else { return }
        guard let string = String(data: data, encoding: .ascii) else { return }
        let ud = UserDefaults.standard
        if characteristic.uuid == SocketIDCharacteristic {
            characteristicCount += 1
            var sockets = ud.object(forKey: "SocketID") as? [String] ?? []
            if !sockets.contains(string) {
                sockets.append(string)
                ud.set(sockets, forKey: "SocketID")
                ud.synchronize()
            }
            
            let delegate = NSApplication.shared().delegate as! AppDelegate
            let service = Service(id: string)
            service.connect()
            delegate.services.append(service)
        }

        if characteristic.uuid == NameCharacteristic {
            characteristicCount += 1
            var names = ud.object(forKey: "Name") as? [String] ?? []
            log.debug("Adding \(string) to Name")
            if !names.contains(string) {
                names.append(string)
                ud.set(names, forKey: "Name")
                ud.synchronize()
            }
        }
        
        guard characteristicCount == 2 else { return }
        controller?.performSegue(withIdentifier: "Success", sender: nil)
    }
}
