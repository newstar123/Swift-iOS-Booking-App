//
//  RidesafeStatus.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/4/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON


final class RidesafeStatus {

    /// Time past in seconds
    var timePast: Int?
    
    /// Time in seconds left to unlock free ride
    var timeLeft: Int?
    
    /// returns true if active promo code is available and can be claimed
    var isFreeRideAvailable: Bool = false
    
    /// Minimal amount should be spent to run free ride countdown
    var minSpendToRide: Int?
    
    /// Minimal time in seconds should be spent in venue
    var ridesafeMinTime: Int?
}

// MARK: - SafeJSONAbleType
extension RidesafeStatus: SafeJSONAbleType {
    
    static var placeholder: RidesafeStatus {
        return RidesafeStatus()
    }
    
    static func from(json: JSON) throws -> RidesafeStatus {
        let status = RidesafeStatus()
        status.timePast = json["time"]["timePastFromFirstOrderInSecs"].int
        status.timeLeft = json["time"]["timeLeftToRideDiscount"].int
        status.isFreeRideAvailable = json["isFreeRideAvailable"].bool ?? false
        status.minSpendToRide = json["minSpendToRideDiscount"].int
        status.ridesafeMinTime = json["time"]["ridesafeMinTimeSecs"].int
        return status
    }
    
}
