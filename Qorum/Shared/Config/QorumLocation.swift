//
//  QorumLocation.swift
//  Qorum
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import CoreLocation

/// The enum which describes Qorum location settings.
enum QorumLocation {
    
    /// Tells to use the real location i.e given from `CLLocationManager`.
    case real
    
    /// Tells to use specified fake location.
    case custom(CLLocationCoordinate2D)
    
    /// Returns fake coordinate or `nil` if real location specified.
    var customCoordinate: CLLocationCoordinate2D? {
        switch self {
        case .real:
            return nil
        case .custom(let coordinate):
            return coordinate
        }
    }
    
    var isReal: Bool {
        return customCoordinate == nil
    }
    
    /// Specifies the constraints for entering fake location coordinates used in the Qorum Config's `MapViewController`.
    static let stringFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimum = -180
        formatter.maximum = 180
        formatter.maximumSignificantDigits = 6
        return formatter
    }()
    
}

// MARK: - Codable
extension QorumLocation: Codable {
    
    enum CodingKeys: CodingKey {
        case latitude
        case longitude
    }
    
    /// Decodes a location. May be defaulted to `real`.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            let container = try decoder.singleValueContainer()
            self = .real
            return
        }
        
        /// Convenience method. Tries to decode a `Double` value from every possible case.
        func getDouble(from key: CodingKeys) -> Double? {
            // legacy support
            if let double = try? container.decode(Double.self, forKey: key) {
                return double
            }
            guard
                let string = try? container.decode(String.self, forKey: key),
                let double = QorumLocation.stringFormatter.number(from: string)?.doubleValue else
            {
                return nil
            }
            return double
        }
        
        guard
            let latitude = getDouble(from: .latitude),
            let longitude = getDouble(from: .longitude) else
        {
            self = .real
            return
        }
        self = .custom(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
    /// Encodes real location as `nil` and fake location as dictionary with coordinates formatted with `stringFormatter`.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any values are invalid for the given encoder’s format.
    func encode(to encoder: Encoder) throws {
        switch self {
        case .real:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case .custom(let coordinate):
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            /// Convenience method. Also formats given coordinate.
            func encode(value: Double, for key: CodingKeys) throws {
                let string = QorumLocation.stringFormatter.string(from: NSNumber(value: value))
                try container.encode(string, forKey: key)
            }
            
            try encode(value: coordinate.latitude, for: .latitude)
            try encode(value: coordinate.longitude, for: .longitude)
        }
    }
    
}

// MARK: - Equatable
extension QorumLocation: Equatable {
    
    static func == (lhs: QorumLocation, rhs: QorumLocation) -> Bool {
        switch (lhs, rhs) {
        case (.real, .real):
            return true
        case (.custom(let leftCoordinate), .custom(let rightCoordinate)) where leftCoordinate == rightCoordinate:
            return true
        default:
            return false
        }
    }
    
}

// MARK: - Equatable
extension CLLocationCoordinate2D: Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
}
