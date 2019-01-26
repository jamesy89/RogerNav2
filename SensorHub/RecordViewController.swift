//
//  RecordViewController.swift
//  SensorHub
//
//  Created by James Yu on 1/9/19.
//  Copyright © 2019 James Yu. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AVFoundation

class RecordViewController: UIViewController, UITextFieldDelegate {
    var isAutoRecording: Bool! = false
    var waypoints: [Waypoint] = []
    var tripName: String?
    var lon: Double?
    var lat: Double?
    var index: Int! = 0
    var timer: Timer?
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var txt_tripName: UITextField!
    @IBOutlet weak var btn_setTripName: UIButton!
    @IBOutlet weak var btn_manualRecord: UIButton!
    @IBOutlet weak var btn_autoRecord: UIButton!
    @IBOutlet weak var btn_completeTrip: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt_tripName.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SensorManager.shared.delegate = self
        SensorManager.shared.startLocationUpdates()
        
        let utterance = AVSpeechUtterance(string: "Start by entering a trip name")
        synthesizer.speak(utterance)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SensorManager.shared.stopLocationUpdates()
    }
    
    @IBAction func completeTrip(_ sender: Any) {
        if (tripName != nil) {
            if (isAutoRecording) {
                timer?.invalidate()
                isAutoRecording = !isAutoRecording
            }
            
            let result = StorageManager.shared.saveTrip(waypoints: waypoints, tripName: tripName!)
            if (result) {
                let alert = UIAlertController(title: "Trip saved", message: "The trip was saved successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                
                let utterance = AVSpeechUtterance(string: "Trip successfully saved")
                synthesizer.speak(utterance)
            }
            else {
                let utterance = AVSpeechUtterance(string: "Trip failed to save")
                synthesizer.speak(utterance)
            }
            
            waypoints = []
            index = 0
            btn_manualRecord.isEnabled = false
            btn_autoRecord.isEnabled = false
            btn_completeTrip.isEnabled = false
            btn_setTripName.isEnabled = true
            txt_tripName.isEnabled = true
            txt_tripName.text = ""
        }
    }
    
    @IBAction func setTripName(_ sender: Any) {
        if let name = txt_tripName.text {
            tripName = name.lowercased()
            
            if StorageManager.shared.tripExists(tripName: tripName!) {
                let alert = UIAlertController(title: "Name already used", message: "The name has already been used, try using a different name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                
                let utterance = AVSpeechUtterance(string: "The name has already been used, try using a different name.")
                synthesizer.speak(utterance)
            }
            else {
                btn_autoRecord.isEnabled = true
                btn_manualRecord.isEnabled = true
                btn_setTripName.isEnabled = false
                txt_tripName.isEnabled = false
                self.view.endEditing(true)
                
                let utterance = AVSpeechUtterance(string: String(format: "Trip name is %@", tripName!))
                synthesizer.speak(utterance)
            }
        }
        else {
            let alert = UIAlertController(title: "Empty name", message: "Please enter a name for your trip.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func manualRecord(_ sender: Any) {
        if (self.lat != nil) {
            let newWaypoint = Waypoint(lat: self.lat!, lon: self.lon!, index: index)
            waypoints.append(newWaypoint)
            index += 1
            
            let utterance = AVSpeechUtterance(string: "Waypoint recorded")
            synthesizer.speak(utterance)
            
            btn_completeTrip.isEnabled = true
        }
        
        /*
        let tmp = Waypoint(lat: 1.0, lon: 2.0, index: 0)
        waypoints.append(tmp)
        
        let tmp1 = Waypoint(lat: 1.0, lon: 2.0, index: 1)
        waypoints.append(tmp1)
        
        do {
            let data = NSKeyedArchiver.archivedData(withRootObject: waypoints)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Trip", in: managedContext)!
            let trip = NSManagedObject(entity: entity, insertInto: managedContext)
            trip.setValue(data, forKey: "waypoints")
            trip.setValue("test", forKey: "name")
            
            try managedContext.save()
        } catch {
            print("Couldn't save array")
        }
        */
    }

    @IBAction func autoRecord(_ sender: Any) {
        isAutoRecording = !isAutoRecording
        
        if (isAutoRecording) {
            btn_autoRecord.setTitle("Stop auto record", for: UIControl.State.normal)
            timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
            
            let utterance = AVSpeechUtterance(string: "Starting auto record")
            synthesizer.speak(utterance)
        }
        else {
            btn_autoRecord.setTitle("Start auto record", for: UIControl.State.normal)
            timer?.invalidate()
            
            let utterance = AVSpeechUtterance(string: "Stopping auto record")
            synthesizer.speak(utterance)
        }
    }
    
    @objc func fireTimer() {
        manualRecord([])
    }
    
}

extension RecordViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
    
    func didUpdateHeading(heading: Double) {
        
    }
    
    func didFail(error: Error) {
        
    }
    
}
