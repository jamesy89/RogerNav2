//
//  StartRogernavViewController.swift
//  SensorHub
//
//  Created by James Yu on 11/26/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit
import CoreLocation

class StartRogernavViewController: UIViewController {
    var heading: Double = 0.0
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    @IBOutlet weak var lbl_lat: UILabel!
    @IBOutlet weak var lbl_lng: UILabel!
    @IBOutlet weak var lbl_heading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        BLEManager.shared.delegate = self
        SensorManager.shared.delegate = self
        SensorManager.shared.startLocationUpdates()
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

extension StartRogernavViewController: BLEDelegate {
    func bleCommRecvd(command: BLECommand) {
        switch command {
        case .Heading:
            let resp = String(format: "HEAD = %f", heading)
            let data = resp.data(using: .utf8)
            BLEManager.shared.writeDataTx(data:data!)
            break
        case .Location:
            let resp = String(format: "DECLAT = %f\nDECLON = %f", lat, lon)
            let data = resp.data(using: .utf8)
            BLEManager.shared.writeDataTx(data:data!)
            break
        }
    }
    
    func bleConnected() {
        
    }
    
    func bleDisconnected() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension StartRogernavViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        //print("Delegate received - location")
        self.lat = lat
        self.lon = lon
        lbl_lat.text = String(format: "%f", lat)
        lbl_lng.text = String(format: "%f", lon)
    }
    
    func didUpdateHeading(heading: Double) {
        //print("Delegate received - heading")
        self.heading = heading
        lbl_heading.text = String(format: "%f˚", heading)
    }
    
    func didFail(error: Error) {
        
    }
    
}
