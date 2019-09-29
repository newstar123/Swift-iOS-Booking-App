//
//  UberEstimate.swift
//  Qorum
//
//  Created by Michael Wilson on 10/22/15.
//  Copyright © 2015 Qorum. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UberEstimate {
    
    // MARK: - Properties
    
    /// Unique identifier representing a specific product for a given latitude & longitude.
    let product_id: String // Required
    
    /// Expected activity duration (in seconds).
    var duration: Int?
    
    /// Display name of product. Ex: "UberBLACK".
    var name: String?
    
    /// Estimated price range for Uber product offered at a location.
    var priceRange: String?
    
    // MARK: - Init/Deinit
    init(product_id: String) {
        self.product_id = product_id
    }
    
}

// MARK: - SafeJSONAbleType
extension UberEstimate: SafeJSONAbleType {
    
    static var placeholder: UberEstimate {
        return UberEstimate(product_id: "")
    }
    
    static func from(json: JSON) throws -> UberEstimate {
        let product_id = try json["product_id"].expectingString()
        let estimate = UberEstimate(product_id: product_id)
        estimate.duration = json["duration"].int
        estimate.name = json["localized_display_name"].string
        estimate.priceRange = json["estimate"].string
        return estimate
    }
    
}

// MARK: - CustomStringConvertible
extension UberEstimate: CustomStringConvertible {
    
    var description: String {
        return "name: \(String(describing: name))"
    }
    
}
