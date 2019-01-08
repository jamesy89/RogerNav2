//
//  Constants.swift
//  SensorHub
//
//  Created by James Yu on 10/10/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Constants {
    static let SERVICE_UUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let RX_UUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static let TX_UUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    static let RX_PROPERTIES: CBCharacteristicProperties = [.write, .writeWithoutResponse]
    static let TX_PROPERTIES: CBCharacteristicProperties = .notify
    static let RX_PERMISSIONS: CBAttributePermissions = .writeable
    static let TX_PERMISSIONS: CBAttributePermissions = .readable
}
