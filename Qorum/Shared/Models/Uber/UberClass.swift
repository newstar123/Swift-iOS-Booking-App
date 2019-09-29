//
//  UberClass.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/15/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

let kEconomyTypesList = ["uberpool", "uberpool1", "pool", "pool1", "uberx", "uberxl"]
let kPremiumTypesList = ["uberselect", "select", "uberblack", "black", "black suv"]
let kOtherTypesList = ["español", "assist", "wav"]

enum UberClassName: String {
    case economy = "Economy"
    case premium = "Premium"
    case other = "Other"
}


class UberClass: NSObject {
    
    /// Uber class type, e.g. 'Economy', 'Premium', etc.
    let name: UberClassName
    
    /// Uber Ride type
    var types: [UberType]
    
    init(name: UberClassName, types: [UberType]) {
        self.name = name
        self.types = types
    }
    
    /// Returns false if estimate is not provided
    ///
    /// - Returns: Bool value
    func hasNotLoadedEstimate() -> Bool {
        let filtered = self.types.filter({ $0.estimate == nil })
        return filtered.count > 0
    }
    
    /// Removes empty estimate entries
    func clearFromEmptyEstimates() {
        var resultTypes: [UberType] = []
        
        for type in self.types {
            if type.estimate?.isEmpty == false {
                resultTypes.append(type)
            }
        }
        
        self.types = resultTypes
    }
    
    /// Returns true if types array is empty
    ///
    /// - Returns: Bool value
    func isEmpty() -> Bool {
        return self.types.count == 0
    }
    
    /// Updates types from UberProduct's array
    ///
    /// - Parameter products: source UberProducts array
    func fill(from products: [UberProduct]) {
        var list: [String] = []
        switch self.name {
        case .economy:
            list = kEconomyTypesList
        case .premium:
            list = kPremiumTypesList
        case .other:
            list = kOtherTypesList
        }
        
        for type in list {
            if let product = products.first(where: { $0.display_name.lowercased() == type }) {
                types.append(UberType(productData: product))
            }
        }
    }

    /// Creates UberClasses array from UberProducts
    ///
    /// - Parameter products: sourse UberProducts array
    /// - Returns: resultin UberClasses array
    class func classesFrom(products: [UberProduct]) -> [UberClass] {
        let classes: [UberClass] = [UberClass(name: UberClassName.economy, types: []),
                                    UberClass(name: UberClassName.premium, types: []),
                                    UberClass(name: UberClassName.other, types: [])]
        
        classes.forEach({ $0.fill(from: products) })
        
        return classes
    }
    
}


