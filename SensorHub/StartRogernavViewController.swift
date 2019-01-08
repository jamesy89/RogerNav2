//
//  StartRogernavViewController.swift
//  SensorHub
//
//  Created by James Yu on 11/26/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit
import CoreLocation

class StartRogernavViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var heading: Double = 0.0
    var lat: Double = 0.0
    var lon: Double = 0.0
    var log_msg: [String] = []
    
    @IBOutlet weak var lbl_lat: UILabel!
    @IBOutlet weak var lbl_lng: UILabel!
    @IBOutlet weak var lbl_heading: UILabel!
    @IBOutlet weak var tableView_log: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        BLEManager.shared.delegate = self
        SensorManager.shared.delegate = self
        SensorManager.shared.startLocationUpdates()
        
        tableView_log.delegate = self
        tableView_log.dataSource = self
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return log_msg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView_log.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = log_msg[indexPath.row]
        
        return cell
    }
    
    func logMsg(msg: String) {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        let dateString = formatter.string(from: now)
        
        let msg1 = dateString + " - " + msg
        log_msg.append(msg1)
        tableView_log.reloadData()
    }
}

extension StartRogernavViewController: BLEDelegate {
    func bleCommRecvd(command: BLECommand) {
        switch command {
        case .Heading:
            logMsg(msg: "Heading request")
            
            let resp = String(format: "HEAD = %f", heading)
            let data = resp.data(using: .utf8)
            BLEManager.shared.writeDataTx(data:data!)
            break
        case .Location:
            logMsg(msg: "GPS request")
            
            var resp = String(format: "DECLAT = %f\n", lat)
            var data = resp.data(using: .utf8)
            BLEManager.shared.writeDataTx(data:data!)
            
            resp = String(format: "DECLON = %f\n", lon)
            data = resp.data(using: .utf8)
            BLEManager.shared.writeDataTx(data:data!)
            break
        case .Rssi:
            logMsg(msg: "RSSI request")
            break
        }
    }
    
    func bleUnknownCommRecvd(commamd: String) {
        let msg = "Unknown request: " + commamd
        logMsg(msg: msg)
    }
    
    func bleConnected() {
        
    }
    
    func bleDisconnected() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.debounceTimer), userInfo: nil, repeats: false)
    }
    
    @objc func debounceTimer() {
        if !BLEManager.shared.connected {
            //self.dismiss(animated: true, completion: nil)
        }
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
