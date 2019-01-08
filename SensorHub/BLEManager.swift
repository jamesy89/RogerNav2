//
//  BLEManager.swift
//  SensorHub
//
//  Created by James Yu on 11/26/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BLECommand {
    case Heading
    case Location
    case Rssi
}

protocol BLEDelegate: AnyObject {
    func bleCommRecvd(command: BLECommand)
    func bleUnknownCommRecvd(commamd: String)
    func bleConnected()
    func bleDisconnected()
}

class BLEManager: NSObject {
    static let shared = BLEManager()
    weak var delegate: BLEDelegate?
    
    var connected: Bool! = false
    var rssi: Int! = 0
    var queuedData: Data? = nil
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral?
    var rx: CBMutableCharacteristic?
    var tx: CBMutableCharacteristic?
    
    private override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func updateAdvertisingData() {
        if (peripheralManager!.isAdvertising) {
            peripheralManager!.stopAdvertising()
        }
        
        let advertisementData = String(format: "%@", "SensorHub")
        peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID], CBAdvertisementDataLocalNameKey:advertisementData])
    }
    
    func initService() {
        let serialService = CBMutableService(type: Constants.SERVICE_UUID, primary: true)
        rx = CBMutableCharacteristic(type: Constants.RX_UUID, properties: Constants.RX_PROPERTIES, value: nil, permissions: Constants.RX_PERMISSIONS)
        tx = CBMutableCharacteristic(type: Constants.TX_UUID, properties: Constants.TX_PROPERTIES, value: nil, permissions: Constants.TX_PERMISSIONS)
        serialService.characteristics = [rx!, tx!]
        
        peripheralManager!.add(serialService)
    }
    
    func writeDataTx(data: Data) {
        let result = peripheralManager!.updateValue(data, for: tx!, onSubscribedCentrals: nil)
        if result == false {
            queuedData = data
        }
        else {
            queuedData = nil
        }
    }
}

extension BLEManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn) {
            print("Peripheral powered on")
            
            initService()
            updateAdvertisingData()
        }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        if queuedData != nil {
            peripheralManager!.updateValue(queuedData!, for: tx!, onSubscribedCentrals: nil)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value {
                let messageText = String(data: value, encoding: String.Encoding.utf8)
                let command = messageText?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                print(String(format: "Received: %@", command!))
                
                if (command!.count > 0) {
                    if (command! == "h") {
                        print("Heading request")
                        /*
                        let resp = String(format: "HEAD = %f", heading!)
                        let data = resp.data(using: .utf8)
                        peripheralManager.updateValue(data!, for: tx!, onSubscribedCentrals: nil)
                        */
                        delegate?.bleCommRecvd(command: .Heading)
                    }
                    else if (command! == "o") {
                        print("GPS request")
                        /*
                        let resp = String(format: "DECLAT = %f\nDECLON = %f", latitude!, longitude!)
                        let data = resp.data(using: .utf8)
                        peripheralManager.updateValue(data!, for: tx!, onSubscribedCentrals: nil)
                        */
                        delegate?.bleCommRecvd(command: .Location)
                    }
                    else if (command! == "r") {
                        print("RSSI request")
                        delegate?.bleCommRecvd(command: .Rssi)
                        
                        let resp = String("RSSI = -100")
                        let data = resp.data(using: .utf8)
                        writeDataTx(data: data!)
                    }
                    else {
                        print("Not recognized")
                        delegate?.bleUnknownCommRecvd(commamd: command!)
                        
                        let resp = String(format: "CMD ERROR")
                        let data = resp.data(using: .utf8)
                        peripheralManager!.updateValue(data!, for: tx!, onSubscribedCentrals: nil)
                    }
                    
                    peripheralManager!.respond(to: request, withResult: .success)
                }
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed")
        
        connected = true
        delegate?.bleConnected()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed")
        
        connected = false
        delegate?.bleDisconnected()
    }
}
