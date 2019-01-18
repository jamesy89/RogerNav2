//
//  PlaybackViewController.swift
//  SensorHub
//
//  Created by James Yu on 1/9/19.
//  Copyright © 2019 James Yu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlaybackViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        StorageManager.shared.loadAllTripInfo()
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
    
}
