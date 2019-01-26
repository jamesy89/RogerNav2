//
//  PlaybackViewController.swift
//  SensorHub
//
//  Created by James Yu on 1/9/19.
//  Copyright © 2019 James Yu. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData

class PlaybackViewController: UIViewController {
    @IBOutlet weak var tableView_trips: UITableView!
    
    var tripInfo: [(String, Date)]? = []
    var selectedTrip: (String, Date)!
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView_trips.delegate = self
        tableView_trips.dataSource = self
        tripInfo = StorageManager.shared.loadAllTripInfo()
        
        let utterance = AVSpeechUtterance(string: "Select a trip from the list")
        synthesizer.speak(utterance)
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        let predicate = NSPredicate(format: "name = %@", argumentArray: ["test1"])
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                let data = result.value(forKey: "waypoints") as! Data
                let unarchiveObj = NSKeyedUnarchiver.unarchiveObject(with: data)
                let arrayObj = unarchiveObj as [Waypoint]!
                for obj in arrayObj! {
                    print(obj)
                }
            }
        } catch {
            print("Failed")
        }
        */
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TripInfoViewController {
            vc.tripInfo = selectedTrip
        }
    }
    
}

extension PlaybackViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripInfo!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView_trips.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath)
        let tripName = tripInfo![indexPath.row].0
        cell.textLabel?.text = tripName
        
        let tripDate = tripInfo![indexPath.row].1
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm:ss"
        let dateString = df.string(from: tripDate)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let tripName = tripInfo![indexPath.row].0
            StorageManager.shared.deleteTrip(tripName: tripName)
            
            tripInfo!.remove(at: indexPath.row)
            tableView_trips.deleteRows(at: [indexPath], with: .fade)
            
            let utterance = AVSpeechUtterance(string: String(format: "Trip %@ deleted", tripName))
            synthesizer.speak(utterance)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrip = tripInfo![indexPath.row]
        performSegue(withIdentifier: "segue_tripinfo", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}
