//
//  CustomLocation.swift
//  Qorum Config
//
//  Created by Stanislav on 1/25/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import CoreLocation

/// The structure for storing and reusing custom locations in the config.
struct CustomLocation: UserDefaultsStorable {
    
    var title: StorableTitle
    
    /// The latitude in degrees.
    let latitude: Double
    
    /// The longitude in degrees.
    let longitude: Double
    
    /// Returns readable description of the coordinate.
    var coordinateString: String {
        guard
            let latitudeString = QorumLocation.stringFormatter.string(from: NSNumber(value: latitude)),
            let longitudeString = QorumLocation.stringFormatter.string(from: NSNumber(value: longitude)) else { return "" }
        return "\(latitudeString) / \(longitudeString)"
    }
    
    static let userDefaultsSuiteName = "CustomLocations"
    
    static var placeholders: [CustomLocation] {
        let chernivtsi = CustomLocation(title: "Chernivtsi", latitude: 48.2726, longitude: 25.9441)
        let losAngeles = CustomLocation(title: "Los Angeles", latitude: 34.0463, longitude: -118.234)
        let minsk = CustomLocation(title: "Minsk", latitude: 53.8862, longitude: 27.5567)
        return [chernivtsi, losAngeles, minsk]
    }
    
    /// Returns `CustomLocation` which is identic to the `AppConfig.location`, or `nil`, if it's real one.
    /// So it's defined as current/selected custom location.
    static var currentUntitled: CustomLocation? {
        switch AppConfig.location {
        case .real:
            return nil
        case .custom(let coordinate):
            return CustomLocation(title: .untitled,
                                  latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        }
    }
    
    func apply() {
        AppConfig.location = .custom(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
}
