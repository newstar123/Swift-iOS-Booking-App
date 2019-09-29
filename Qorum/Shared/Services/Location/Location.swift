//
//  Location.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/5/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    var name: String
    var coordinate: CLLocationCoordinate2D
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }
}
