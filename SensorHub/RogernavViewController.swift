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
    var longitude: Double?
    var latitude: Double?
    var heading: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        BLEManager.shared.delegate = self
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
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? StartRogernavViewController {
            
        }
    }
 
}

extension RogernavViewController: BLEDelegate {
    func bleCommRecvd(command: BLECommand) {
        
    }
    
    func bleUnknownCommRecvd(commamd: String) {
        
    }
    
    func bleConnected() {
        print("RogerNav connected")
        performSegue(withIdentifier: "segue_startRogernav", sender: nil)
    }
    
    func bleDisconnected() {
        
    }
    
}

extension RogernavViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        
    }
    
    func didUpdateHeading(heading: Double) {
        
    }
    
    func didFail(error: Error) {
        
    }
    
}
