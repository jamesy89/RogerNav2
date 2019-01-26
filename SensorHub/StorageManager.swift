//
//  StorageManager.swift
//  SensorHub
//
//  Created by James Yu on 11/14/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct WaypointStruct {
    var lon = 0.0
    var lat = 0.0
    var ind = 0
}

class StorageManager: NSObject {
    static let shared = StorageManager()
    
    private override init() {
        super.init()
        
    }
    
    func saveTrip(waypoints: [Waypoint], tripName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: managedContext)!
        let trip = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: waypoints)
        trip.setValue(tripName, forKeyPath: "name")
        trip.setValue(Date(), forKey: "date")
        trip.setValue(data, forKey: "waypoints")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
        
        return true
    }
    
    func loadAllTripInfo() -> [(String, Date)] {
        var tripInfo: [(String, Date)] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                let tripName = result.value(forKey: "name") as? String
                let tripDate = result.value(forKey: "date") as? Date
                
                if (tripName != nil && tripDate != nil) {
                    tripInfo.append((tripName!, tripDate!))
                }
            }
        } catch {
            print("Failed")
        }
        
        return tripInfo
    }
    
    func deleteTrip(tripName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        let predicate = NSPredicate(format: "name = %@", argumentArray: [tripName])
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                managedContext.delete(result)
            }
            try managedContext.save()
            
            return true
        } catch {
            print("Failed")
        }
        
        return false
    }
    
    func loadTrip(tripName: String) -> [Waypoint]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        let predicate = NSPredicate(format: "name = %@", argumentArray: [tripName])
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                let data = result.value(forKey: "waypoints") as! Data
                let unarchiveObj = NSKeyedUnarchiver.unarchiveObject(with: data)
                let arrayObj = unarchiveObj as! [Waypoint]!
                
                return arrayObj
            }
        } catch {
            print("Failed")
        }
        
        return nil
    }
    
    func tripExists(tripName: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Trip")
        let predicate = NSPredicate(format: "name = %@", argumentArray: [tripName])
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if (result.count > 0) {
                return true
            }
            
            return false
        } catch {
            print("Failed")
        }
        
        return false
    }
}
