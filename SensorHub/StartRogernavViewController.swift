//
//  StartRogernavViewController.swift
//  SensorHub
//
//  Created by James Yu on 11/26/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit

class StartRogernavViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
/*
extension StartRogernavViewController: CBPeripheralManagerDelegate {
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
        //
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        //
    }
}
*/
