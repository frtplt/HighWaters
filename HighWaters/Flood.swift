//
//  Flood.swift
//  HighWaters
//
//  Created by Firat on 24.02.2022.
//

import Foundation

struct Flood {
    
    var longitude: Double
    var latitude: Double
    
    func toDictionary() -> [String:Any] {
        return ["longitude": self.longitude, "latitude": self.latitude]
    }
}

extension Flood {
    
    init?(dictionary:[String:Any]) {
        
        guard let latitude = dictionary["latitude"] as? Double,
              let longitude = dictionary["longitude"] as? Double else { return nil }
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
}
