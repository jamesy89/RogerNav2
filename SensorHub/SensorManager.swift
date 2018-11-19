//
//  Sensor.swift
//  SensorHub
//
//  Created by James Yu on 11/13/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

protocol SensorDelegate: AnyObject {
    func didUpdateLocation(lat: Double, lon: Double)
    func didUpdateHeading(heading: Double)
    func didFail(error: Error)
}

class SensorManager: NSObject {
    static let shared = SensorManager()
    weak var delegate: SensorDelegate?
    
    var currCoord: CLLocationCoordinate2D?
    var currHead: CLHeading?
    
    var motionManager: CMMotionManager?
    var locationManager: CLLocationManager?
    
    private override init() {
        super.init()
        
        motionManager = CMMotionManager()
        locationManager = CLLocationManager()
        locationManager!.delegate = self
    }
    
    func startLocationUpdates() {
        motionManager!.startDeviceMotionUpdates()
        motionManager!.startMagnetometerUpdates()
        
        locationManager!.startUpdatingLocation()
        locationManager!.startUpdatingHeading()
    }
    
    func stopLocationUpdates() {
        motionManager!.stopDeviceMotionUpdates()
        motionManager!.stopMagnetometerUpdates()
        
        locationManager!.stopUpdatingLocation()
        locationManager!.stopUpdatingHeading()
    }
    
    func requestLocation() -> CLLocationCoordinate2D {
        return currCoord!
    }
}

extension SensorManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            currCoord = location.coordinate
            /*
            print(String(format: "Coord: %f, %f, +/- %fm", currCoord!.longitude, currCoord!.latitude, location.horizontalAccuracy))
            print(String(format: "Speed: %f", location.speed))
            */
            delegate?.didUpdateLocation(lat: currCoord!.latitude, lon: currCoord!.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currHead = newHeading
        
        // print(String(format: "Heading: %f", currHead!.trueHeading))
        delegate?.didUpdateHeading(heading: currHead!.trueHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let err = error
        
        print(String(format: "Error: %@", err.localizedDescription))
        delegate?.didFail(error: err)
    }
}
