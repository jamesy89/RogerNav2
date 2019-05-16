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
import AVFoundation

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
    let synthesizer = AVSpeechSynthesizer()
    
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
    
    func speakLocation() {
        let dms = convertDMS(lat: currCoord!.latitude, lng: currCoord!.longitude)
        let utterance = AVSpeechUtterance(string: dms)
        synthesizer.speak(utterance)
    }
    
    func toDegreesMinutesAndSeconds(coordinate: Double) -> String {
        let absolute = abs(coordinate)
        let degrees = floor(absolute)
        let minutesNotTruncated = (absolute - degrees) * 60
        let minutes = floor(minutesNotTruncated)
        let seconds = floor((minutesNotTruncated - minutes) * 60)
        
        return String(format: "%d degrees %d minutes %d seconds", Int(degrees), Int(minutes), Int(seconds))
    }
    
    func convertDMS(lat: Double, lng: Double) -> String {
        let latitude = toDegreesMinutesAndSeconds(coordinate: lat)
        let latitudeCardinal = lat >= 0 ? "North" : "South"
    
        let longitude = toDegreesMinutesAndSeconds(coordinate: lng)
        let longitudeCardinal = lng >= 0 ? "East" : "West"
    
        //print(latitude + " " + latitudeCardinal + ", " + longitude + " " + longitudeCardinal)
        return latitude + " " + latitudeCardinal + ", " + longitude + " " + longitudeCardinal
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
