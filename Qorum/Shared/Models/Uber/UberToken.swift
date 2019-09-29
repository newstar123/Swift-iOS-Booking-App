//
//  UberToken.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/5/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON
import UberRides
import UberCore

class UberToken: NSObject, NSCoding {
    
    /// The Access Token Identifier. The identifier to use for looking up this client's accessToken
    var accessToken: String?
    
    /// The Refresh Token String from an SSO access token
    var refreshToken: String?
    
    /// Access Token token expiration time
    var expires: Date?
    
    init(json: JSON) {
        self.accessToken = json["access_token"].string
        self.refreshToken = json["refresh_token"].string
        if let expiresIn = json["expires_in"].double {
            self.expires = Date(timeIntervalSinceNow: expiresIn)
        }
    }
    
    init(acessToken: String?, refreshToken: String?, expiresIn: Double?) {
        self.accessToken = acessToken
        self.refreshToken = refreshToken
        if let expiresIn = expiresIn {
            self.expires = Date(timeIntervalSinceNow: expiresIn)
        }
    }
    
    init(accessToken: AccessToken?) {
        self.accessToken = accessToken?.tokenString
        self.refreshToken = accessToken?.refreshToken
        
        if let expiresIn = accessToken?.expirationDate {
            self.expires = expiresIn
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String
        refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String
        expires = aDecoder.decodeObject(forKey: "expires") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(accessToken, forKey: "accessToken")
        aCoder.encode(refreshToken, forKey: "refreshToken")
        aCoder.encode(expires, forKey: "expires")
    }
}

class UberRequestData {
    
    /// Uber ride type
    var type: UberType?
    
    /// Pickup location coordinate for the trip.
    var pickup: CLLocationCoordinate2D?
    
    /// Uber dropoff location coordinate
    var dropoff: CLLocationCoordinate2D?
    
    /// Uber pickup address
    var pickupAddress: String?
    
    /// Uber dropoff address
    var dropoffAddress: String?
    
    /// Seats requested
    var seatsCount: Int?
    
    /// Uber ride type for Qorum - to/from Venue or free ride
    var qorumRideType: QorumRideType?
    
    /// The unique identifier of the surge session for a user. Nil for no surge.
    var surgeConfirmationId: String?
    
    init(type: UberType, pickup: CLLocationCoordinate2D, dropoff: CLLocationCoordinate2D, pickupAddress: String?, dropoffAddress: String?, seatsCount: Int?, qorumRideType: QorumRideType?) {
        self.type = type
        self.pickup = pickup
        self.dropoff = dropoff
        self.pickupAddress = pickupAddress
        self.dropoffAddress = dropoffAddress
        self.seatsCount = seatsCount
        self.qorumRideType = qorumRideType
    }
}

class UberTrip {
    
    /// The object containing the information about trip estimation.
    var estimate: UberEstimate?
    
    /// Uber pickup location coordinate
    var pickup: CLLocationCoordinate2D?

    /// Uber dropoff location coordinate
    var dropoff: CLLocationCoordinate2D?
    
    /// Uber pickup address
    var pickupAddress: String?
    
    /// Uber dropoff address
    var dropoffAddress: String?
    
    /// Uber ride type
    var rideType: String?
    
    /// The unique identifier of the surge session for a user. Nil for no surge.
    var surgeConfirmationId: String?
    
    init(pickup: CLLocationCoordinate2D, dropoff: CLLocationCoordinate2D, pickupAddress: String, dropoffAddress: String, estimate: UberEstimate, rideType: String) {
        self.estimate = estimate
        self.pickup = pickup
        self.dropoff = dropoff
        self.pickupAddress = pickupAddress
        self.dropoffAddress = dropoffAddress
        self.rideType = rideType
    }
}
