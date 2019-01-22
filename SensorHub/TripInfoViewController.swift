//
//  TripInfoViewController.swift
//  SensorHub
//
//  Created by James Yu on 1/21/19.
//  Copyright © 2019 James Yu. All rights reserved.
//

import UIKit

class TripInfoViewController: UIViewController {
    var tripInfo: (String, Date)!
    var waypoints: [Waypoint]!
    var tripStarted: Bool! = false

    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_numWaypoints: UILabel!
    @IBOutlet weak var tableView_waypoints: UITableView!
    
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
        
        tableView_waypoints.delegate = self
        tableView_waypoints.dataSource = self
        waypoints = StorageManager.shared.loadTrip(tripName: tripInfo.0)
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm:ss"
        let dateString = df.string(from: tripInfo.1)
        
        lbl_date.text = dateString
        lbl_name.text = tripInfo.0
        lbl_numWaypoints.text = String(format: "%d waypoints", waypoints.count)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func startTrip(_ sender: Any) {
        tripStarted = !tripStarted
        
        if (tripStarted) {
            
        }
        else {
            
        }
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
