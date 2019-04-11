//
//  StandaloneViewController.swift
//  SensorHub
//
//  Created by James Yu on 10/8/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import AVFoundation

class StandaloneViewController: UIViewController {
    @IBOutlet weak var btn_mrbeep: UIButton!
    @IBOutlet weak var btn_record: UIButton!
    @IBOutlet weak var btn_playback: UIButton!
    
    var motionManager = CMMotionManager()
    var locationManager = CLLocationManager()
    var timer = Timer()
    
    var longitude: Double?
    var latitude: Double?
    var heading: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        motionManager.startDeviceMotionUpdates()
        motionManager.startMagnetometerUpdates()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        */
        
        //scheduledTimerWithTimeInterval()
        /*
        let string = "Hello, World!"
        let utterance = AVSpeechUtterance(string: string)
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
         */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SensorManager.shared.delegate = self
        SensorManager.shared.startLocationUpdates()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func mrbeep(_ sender: Any) {
        performSegue(withIdentifier: "segue_mrbeep", sender: nil)
    }
    
    @IBAction func record(_ sender: Any) {
        performSegue(withIdentifier: "segue_record", sender: nil)
    }
    
    @IBAction func playback(_ sender: Any) {
        performSegue(withIdentifier: "segue_playback", sender: nil)
    }
    
    @IBAction func speakLocation(_ sender: Any) {
        SensorManager.shared.speakLocation()
    }
    
}

extension StandaloneViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        
    }
    
    func didUpdateHeading(heading: Double) {
        
    }
    
    func didFail(error: Error) {
        
    }
}

extension StandaloneViewController: CLLocationManagerDelegate {
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
