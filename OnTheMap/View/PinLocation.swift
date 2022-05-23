//
//  PinLocation.swift
//  OnTheMap
//
//  Created by Kenneth Gutierrez on 5/23/22.
//

import Foundation
import MapKit

class PinLocation: NSObject, MKAnnotation {
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    init(locationName: String?, coordinate: CLLocationCoordinate2D) {
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
