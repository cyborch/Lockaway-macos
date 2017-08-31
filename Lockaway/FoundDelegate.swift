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

class FoundDelegate: NSObject, CBPeripheralDelegate {
    
    @IBOutlet var controller: NSViewController?
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        for service in peripheral.services ?? [] {
            guard service.uuid == ConfigurationService else { continue }
            peripheral.discoverCharacteristics([SocketIDCharacteristic], for: service)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard service.uuid == ConfigurationService else { return }
        for characteristic in service.characteristics ?? [] {
            guard characteristic.uuid == SocketIDCharacteristic else { continue }
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == SocketIDCharacteristic else { return }
        guard error == nil else { return }
        guard let data = characteristic.value else { return }
        guard let string = String(data: data, encoding: .ascii) else { return }
        
        let ud = UserDefaults.standard
        var sockets = ud.object(forKey: "SocketID") as? [String] ?? []
        sockets.append(string)
        ud.set(sockets, forKey: "SocketID")
        ud.synchronize()
        
        let delegate = NSApplication.shared().delegate as! AppDelegate
        let service = Service(id: string)
        service.connect()
        delegate.services.append(service)
        
        controller?.performSegue(withIdentifier: "Success", sender: nil)
    }
}
