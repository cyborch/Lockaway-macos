//
//  PairDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import CoreBluetooth

let ConfigurationService = CBUUID(string: "EFC325B2-2281-4BB4-9196-8A8904980ABF")

class PairDelegate: NSObject, CBCentralManagerDelegate {
    enum NoBluetoothError: Error {
        case unsupported, unauthorized
        
        var localizedDescription: String {
            get {
                switch self {
                case .unauthorized:
                    return "Bluetooth is not allowed on this computer, please contact your administrator."
                case .unsupported:
                    return "This comnputer does not support Bluetooth."
                }
            }
        }
        
        init?(state: CBCentralManagerState) {
            switch state {
            case .unauthorized:
                self = .unauthorized
            case .unsupported:
                self = .unsupported
            default:
                return nil
            }
        }
    }
    
    @IBOutlet var controller: NSViewController?
    
    private var shouldScan = false
    private var isScanning = false
    
    func startScan(manager: CBCentralManager) {
        shouldScan = true
        if manager.state == .poweredOn && !isScanning {
            print("starting scanning")
            manager.scanForPeripherals(withServices: [ConfigurationService], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            isScanning = true
        }
    }
    
    func stopScan(manager: CBCentralManager) {
        guard isScanning else { return }
        isScanning = false
        print("stopping scanning")
        manager.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state is: \(central.state.rawValue)")
        if central.state == .poweredOn && shouldScan && !isScanning {
            print("starting scanning")
            central.scanForPeripherals(withServices: [ConfigurationService], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            isScanning = true
        }
        guard let error = NoBluetoothError(state: central.state) else { return }
        let alert = NSAlert(error: error)
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discovered: \(String(describing: peripheral.name))")
        showFound(peripheral: peripheral)
        stopScan(manager: central)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([ConfigurationService])
    }

    func showFound(peripheral: CBPeripheral) {
        controller?.performSegue(withIdentifier: "Found", sender: peripheral)
    }
    
}
