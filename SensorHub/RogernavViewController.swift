//
//  RogernavViewController.swift
//  SensorHub
//
//  Created by James Yu on 10/8/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion
import CoreLocation

class RogernavViewController: UIViewController {
    var peripheralManager = CBPeripheralManager()
    var peripheral: CBPeripheral?
    var motionManager = CMMotionManager()
    var locationManager = CLLocationManager()
    var timer = Timer()
    
    var rx: CBMutableCharacteristic?
    var tx: CBMutableCharacteristic?
    
    var longitude: Double?
    var latitude: Double?
    var heading: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        motionManager.startDeviceMotionUpdates()
        motionManager.startMagnetometerUpdates()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        scheduledTimerWithTimeInterval()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //updateAdvertisingData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopMagnetometerUpdates()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.sendUpdates), userInfo: nil, repeats: true)
    }
    
    @objc func sendUpdates() {
        let magData = motionManager.magnetometerData
        let motionData = motionManager.deviceMotion
        
        //print(String(format: "<#T##String#>", <#T##arguments: CVarArg...##CVarArg#>))
    }
    
    func updateAdvertisingData() {
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let advertisementData = String(format: "%@", "SensorHub")
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID],
                                            CBAdvertisementDataLocalNameKey:advertisementData])
    }
    
    func initService() {
        let serialService = CBMutableService(type: Constants.SERVICE_UUID, primary: true)
        rx = CBMutableCharacteristic(type: Constants.RX_UUID, properties: Constants.RX_PROPERTIES, value: nil, permissions: Constants.RX_PERMISSIONS)
        tx = CBMutableCharacteristic(type: Constants.TX_UUID, properties: Constants.TX_PROPERTIES, value: nil, permissions: Constants.TX_PERMISSIONS)
        serialService.characteristics = [rx!, tx!]
        
        peripheralManager.add(serialService)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RogernavViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let coord = location.coordinate
            //let time = location.timestamp
            longitude = coord.longitude
            latitude = coord.latitude
            
            print(String(format: "Coord: %f, %f, +/- %fm", coord.longitude, coord.latitude, location.horizontalAccuracy))
            print(String(format: "Speed: %f", location.speed))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let nHeading = newHeading
        heading = nHeading.trueHeading
        
        print(String(format: "Heading: %f", nHeading.trueHeading))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let err = error
        
        print(String(format: "Error: %@", err.localizedDescription))
    }
}

extension RogernavViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn) {
            print("Peripheral powered on")
            
            initService()
            updateAdvertisingData()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value {
                let messageText = String(data: value, encoding: String.Encoding.utf8)
                let command = messageText?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                print(String(format: "Received: %@", command!))
                
                if (command! == "h") {
                    print("Heading request")
                    
                    let resp = String(format: "HEAD = %f", heading!)
                    let data = resp.data(using: .utf8)
                    peripheralManager.updateValue(data!, for: tx!, onSubscribedCentrals: nil)
                }
                else if (command! == "o") {
                    print("GPS request")
                    
                    let resp = String(format: "DECLAT = %f\nDECLON = %f", latitude!, longitude!)
                    let data = resp.data(using: .utf8)
                    peripheralManager.updateValue(data!, for: tx!, onSubscribedCentrals: nil)
                }
                else {
                    print("Not recognized")
                    
                    let resp = String(format: "CMD ERROR")
                    let data = resp.data(using: .utf8)
                    peripheralManager.updateValue(data!, for: tx!, onSubscribedCentrals: nil)
                }
                
                self.peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Central unsubscribed")
    }
}
