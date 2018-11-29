//
//  MrBeepViewController.swift
//  SensorHub
//
//  Created by James Yu on 11/12/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit
import AVFoundation

class MrBeepViewController: UIViewController {
    @IBOutlet var lbl_lat: UILabel!
    @IBOutlet var lbl_lon: UILabel!
    @IBOutlet var lbl_heading: UILabel!
    @IBOutlet var btn_setHeading: UIButton!
    
    var setHeading: Double?
    let synthesizer = AVSpeechSynthesizer()
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SensorManager.shared.startLocationUpdates()
        SensorManager.shared.delegate = self
        
        scheduledTimerWithTimeInterval()
        
        let utterance = AVSpeechUtterance(string: "Current heading")
        synthesizer.speak(utterance)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate()
    }
    
    func scheduledTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.sendUpdates), userInfo: nil, repeats: true)
    }
    
    @objc func sendUpdates() {
        let utterance = AVSpeechUtterance(string: String(format: "%d degrees", Int(setHeading!)))
        synthesizer.speak(utterance)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StartMrBeepViewController {
            vc.setHeading = setHeading
        }
    }

    @IBAction func setHeading(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: String(format: "Set heading to %d degrees", Int(setHeading!)))
        synthesizer.speak(utterance)
        
        performSegue(withIdentifier: "segue_startMrbeep", sender: nil)
    }
}

extension MrBeepViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        print("Delegate received - location")
        
        lbl_lat.text = String(format: "%f", lat)
        lbl_lon.text = String(format: "%f", lon)
    }
    
    func didUpdateHeading(heading: Double) {
        print("Delegate received - heading")
        
        setHeading = heading
        lbl_heading.text = String(format: "%f˚", heading)
    }
    
    func didFail(error: Error) {
        
    }
}
