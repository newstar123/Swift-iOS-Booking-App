//
//  UberTypeEstimate.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/30/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberTypeEstimate: NSObject {
    
    /// Estimated price
    let price: Double
    
    /// Upfront Fare ID for the Ride Estimate.
    let fareId: String
    
    /// ISO 4217 currency code.
    let currencyCode: String
    
    /// Expected activity duration (in seconds).
    let duration: Double
    
    /// The unit of distance (mile or km).
    let distanceUnit: String
    
    /// Expected activity distance.
    let distance: Double
    
    /// The estimated time of vehicle arrival in minutes.
    let pickupEstimate: Double
    
    /// Estimated price breakdown
    var breakdown: EstimateBreakdown?
    
    /// Returns true for valid Uber estimate
    var isEmpty = false
    
    init(data: [String: Any]) {
        guard
            let fare = data["fare"] as? [String: Any],
            let trip = data["trip"] as? [String: Any] else
        {
            self.price = 0
            self.fareId = ""
            self.currencyCode = ""
            self.distance = 0
            self.distanceUnit = ""
            self.duration = 0
            self.pickupEstimate = 0
            self.isEmpty = true
            return
        }
        self.price = fare["value"] as! Double
        self.fareId = fare["fare_id"] as! String
        self.currencyCode = fare["currency_code"] as! String
        
        self.distance = trip["distance_estimate"] as! Double
        self.distanceUnit = trip["distance_unit"] as! String
        self.duration = trip["duration_estimate"] as! Double
        
        self.pickupEstimate = data["pickup_estimate"] as? Double ?? 0
        
        if let breakdown = fare["breakdown"] as? [[String : Any]] {
            self.breakdown = EstimateBreakdown(data: breakdown)
        }
        
    }
    
    /// Returns currency symbol depending on code
    ///
    /// - Returns: Currency symbol
    func currencySymbol() -> String {
        let locale = NSLocale(localeIdentifier: currencyCode)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: currencyCode) ?? currencyCode
    }

}

class EstimateBreakdown: NSObject {
    
    /// Promotion adjustment
    var promotion: BreakdownType?
    
    /// Base fare
    var baseFare: BreakdownType?
    
    init(data: [[String: Any]]) {
        if  let promotionData = data.first(where: { $0["type"] as? String == "promotion" }),
            let promotionName = promotionData["name"] as? String,
            let promotionValue = promotionData["value"] as? Double
        {
            self.promotion = BreakdownType(name: promotionName, value: promotionValue)
        }
        
        if  let baseFareData = data.first(where: { $0["type"] as? String == "base_fare" }),
            let fareName = baseFareData["name"] as? String,
            let fareValue = baseFareData["value"] as? Double
        {
            self.baseFare = BreakdownType(name: fareName, value: fareValue)
        }
    }
    
}

class BreakdownType: NSObject {
    
    /// Name of the upfront fare component
    var name: String?
    
    /// Value of the upfront fare component
    var value: Double?
    
    init(name: String?, value: Double?) {
        self.name = name
        self.value = value
    }
}
