//
//  TripInfoViewController.swift
//  SensorHub
//
//  Created by James Yu on 1/21/19.
//  Copyright © 2019 James Yu. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

enum Direction: String {
    case Left = "turn left"
    case Right = "turn right"
    case Front = "keep straight"
}

class TripInfoViewController: UIViewController {
    var tripInfo: (String, Date)!
    var currHeading: Double! = 0.0
    var currCoord: Waypoint! = Waypoint()
    var waypoints: [Waypoint]!
    var currWaypointInd: Int! = 0
    var totalWaypoints: Int!
    var tripStarted: Bool! = false
    var timer: Timer?
    var waypointProx: Int!
    let synthesizer = AVSpeechSynthesizer()

    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_numWaypoints: UILabel!
    @IBOutlet weak var tableView_waypoints: UITableView!
    @IBOutlet weak var btn_startTrip: UIButton!
    @IBOutlet weak var lbl_waypointProx: UILabel!
    @IBOutlet weak var slider_waypointProx: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SensorManager.shared.delegate = self
        SensorManager.shared.startLocationUpdates()
        
        tableView_waypoints.delegate = self
        tableView_waypoints.dataSource = self
        waypoints = StorageManager.shared.loadTrip(tripName: tripInfo.0)
        totalWaypoints = waypoints.count
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm:ss"
        let dateString = df.string(from: tripInfo.1)
        
        waypointProx = Int(slider_waypointProx.value)
        lbl_waypointProx.text = String(format: "%i meters", Int(slider_waypointProx.value))
        
        lbl_date.text = dateString
        lbl_name.text = tripInfo.0
        lbl_numWaypoints.text = String(format: "%d waypoints", waypoints.count)
        
        let utterance = AVSpeechUtterance(string: "Start trip when ready")
        synthesizer.speak(utterance)
        
        reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SensorManager.shared.stopLocationUpdates()
        timer?.invalidate()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func reset() {
        btn_startTrip.setTitle("Start trip", for: UIControl.State.normal)
        tripStarted = false
        tableView_waypoints.deselectRow(at: IndexPath(row: currWaypointInd, section: 0), animated: false)
        currWaypointInd = 0
    }

    @IBAction func startTrip(_ sender: Any) {
        tripStarted = !tripStarted
        
        if (tripStarted) {
            btn_startTrip.setTitle("Pause trip", for: UIControl.State.normal)
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
            
            if (currWaypointInd == 0) {
                print("Starting trip")
                let utterance = AVSpeechUtterance(string: "Starting trip")
                synthesizer.speak(utterance)
                
                let startInd = getStartWaypointInd()
                currWaypointInd = startInd
            }
            else {
                print("Resuming trip")
                let utterance = AVSpeechUtterance(string: "Resuming trip")
                synthesizer.speak(utterance)
            }
        }
        else {
            btn_startTrip.setTitle("Resume trip", for: UIControl.State.normal)
            timer?.invalidate()
            
            print("Trip paused")
            let utterance = AVSpeechUtterance(string: "Trip paused")
            synthesizer.speak(utterance)
        }
    }
    
    @IBAction func speakLocation(_ sender: Any) {
        let utterance = AVSpeechUtterance(string: String(format: "Longitude is %f, latitude is %f", currCoord.lon, currCoord.lat))
        synthesizer.speak(utterance)
    }
    
    @objc func fireTimer() {
        let nextWaypoint = waypoints[currWaypointInd]
        tableView_waypoints.selectRow(at: IndexPath(row: currWaypointInd, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        
        doTripActions(nextWaypoint: nextWaypoint)
    }
    
    func doTripActions(nextWaypoint: Waypoint) {
        print(String(format: "Next waypoint: %d/%d - %f, %f", nextWaypoint.index+1, totalWaypoints, nextWaypoint.lon, nextWaypoint.lat))
        
        let distToWaypoint = distBetween(start: currCoord!, end: nextWaypoint)
        print(String(format: "Distance to next waypoint: %f", distToWaypoint))
        
        if (currWaypointInd < totalWaypoints - 1) {
            let nNextWaypoint = waypoints[currWaypointInd + 1]
            let distToNextWaypoint = distBetween(start: currCoord!, end: nNextWaypoint)
            print(String(format: "Distance to next next waypoint: %f", distToNextWaypoint))
            
            if (distToNextWaypoint <= distToWaypoint) {
                print("Skip to next waypoint")
                currWaypointInd += 1
                
                let utterance = AVSpeechUtterance(string: "Waypoint skipped")
                synthesizer.speak(utterance)
                
                return
            }
        }
        
        let courseHeading = courseTo(start: currCoord!, end: nextWaypoint)
        print(String(format: "Course heading: %f, Current heading: %f", courseHeading, currHeading))
        
        let turnDir = computeUserAction(dist: distToWaypoint, heading: courseHeading, currHeading: currHeading)
        let utterance = AVSpeechUtterance(string: turnDir.rawValue)
        synthesizer.speak(utterance)
        
        if (distToWaypoint <= Double(waypointProx!)) {
            print("Waypoint reached")
            let utterance = AVSpeechUtterance(string: "Waypoint reached")
            synthesizer.speak(utterance)
            
            if (currWaypointInd == totalWaypoints - 1) {
                print("Trip complete")
                timer?.invalidate()
                
                let utterance = AVSpeechUtterance(string: "Trip complete")
                synthesizer.speak(utterance)
                
                reset()
                
                return
            }
            
            if (currWaypointInd < totalWaypoints) {
                currWaypointInd += 1
            }
        }
    }
    
    func computeUserAction(dist: Double, heading: Double, currHeading: Double) -> Direction {
        var turnDir: Direction! = .Front
        let headingDiff = heading - currHeading
        let absHeadingDiff = abs(headingDiff)
        print(String(format: "Off course by: %f", absHeadingDiff))
        
        if (headingDiff > 0.0) {
            if (absHeadingDiff < 180.0) {
                turnDir = .Right
            }
            else {
                turnDir = .Left
            }
        }
        else {
            if (absHeadingDiff < 180.0) {
                turnDir = .Left
            }
            else {
                turnDir = .Right
            }
        }
        
        if (absHeadingDiff <= 10.0) {
            turnDir = .Front
        }
        
        return turnDir
    }
    
    func getStartWaypointInd() -> Int {
        let finalWaypoint = waypoints[waypoints.count-1]
        let distToDest = distBetween(start: currCoord!, end: finalWaypoint)
        print(String(format: "Distance to final waypoint: %f", distToDest))
        
        for waypoint in waypoints {
            let totalDist = distBetween(start: waypoint, end: finalWaypoint)
            if (totalDist < distToDest) {
                print(String(format: "Start at waypoint %d", waypoint.index))
                
                return waypoint.index
            }
        }
        
        return 0
    }
    
    func courseTo(start: Waypoint, end: Waypoint) -> Double {
        let dlon = (end.lon-start.lon).degreesToRadians
        let lat1 = start.lat.degreesToRadians
        let lat2 = end.lat.degreesToRadians
        
        let a1 = sin(dlon) * cos(lat2)
        var a2 = sin(lat1) * cos(lat2) * cos(dlon)
        a2 = cos(lat1) * sin(lat2) - a2
        a2 = atan2(a1, a2)
        
        if (a2 < 0.0) {
            a2 += 2 * Double.pi
        }
        
        return a2.radiansToDegrees
    }
    
    func distBetween(start: Waypoint, end: Waypoint) -> Double {
        var delta = (start.lon - end.lon).degreesToRadians
        let sdlon = sin(delta)
        let cdlon = cos(delta)
        let lat1 = start.lat.degreesToRadians
        let lat2 = end.lat.degreesToRadians
        let slat1 = sin(lat1)
        let clat1 = cos(lat1)
        let slat2 = sin(lat2)
        let clat2 = cos(lat2)
        
        delta = (clat1 * slat2) - (slat1 * clat2 * cdlon)
        delta = pow(delta, 2)
        delta += pow(clat2 * sdlon, 2)
        delta = sqrt(delta)
        
        let denom = (slat1 * slat2) + (clat1 * clat2 * cdlon)
        delta = atan2(delta, denom)
        
        return delta * 6372795
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        lbl_waypointProx.text = String(format: "%i meters", Int(slider_waypointProx.value))
    }
}

extension TripInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView_waypoints.dequeueReusableCell(withIdentifier: "waypointCell", for: indexPath)
        
        let waypoint = waypoints[indexPath.row]
        let coordStr = String(format: "%d: %f, %f", waypoint.index, waypoint.lat, waypoint.lon)
        cell.textLabel?.text = coordStr
        
        return cell
    }
}

extension TripInfoViewController: SensorDelegate {
    func didUpdateLocation(lat: Double, lon: Double) {
        currCoord?.lat = lat
        currCoord?.lon = lon
        //print("didUpdateLocation()")
    }
    
    func didUpdateHeading(heading: Double) {
        currHeading = heading
        //print("didUpdateHeading()")
    }
    
    func didFail(error: Error) {
        
    }
    
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
