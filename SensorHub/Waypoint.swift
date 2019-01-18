//
//  Waypoint.swift
//  SensorHub
//
//  Created by James Yu on 1/11/19.
//  Copyright © 2019 James Yu. All rights reserved.
//

import Foundation

enum Keys: String {
    case latitude = "latitude"
    case longitude = "longitude"
    case index = "index"
}

class Waypoint: NSObject, NSCoding {
    var lat: Double
    var lon: Double
    var index: Int
    
    override init() {
        self.lat = 0.0
        self.lon = 0.0
        self.index = 0
    }
    
    init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
        self.index = 0
    }
    
    init(lat: Double, lon: Double, index: Int) {
        self.lat = lat
        self.lon = lon
        self.index = index
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.lat, forKey: Keys.latitude.rawValue)
        aCoder.encode(self.lon, forKey: Keys.longitude.rawValue)
        aCoder.encode(self.index, forKey: Keys.index.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let lat = aDecoder.decodeDouble(forKey: Keys.latitude.rawValue)
        let lon = aDecoder.decodeDouble(forKey: Keys.longitude.rawValue)
        let index = aDecoder.decodeInteger(forKey: Keys.index.rawValue)
        
        self.init(lat: lat, lon: lon, index: index)
    }
    
}
