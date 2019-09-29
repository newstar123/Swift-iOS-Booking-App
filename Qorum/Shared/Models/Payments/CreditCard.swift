//
//  CreditCard.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/28/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

final class CreditCard {
    
    /// Credit card record id
    let id: String
    
    /// Credit card expiration month
    let expiryMonth: UInt
    
    /// Credit card expiration year
    let expiryYear: UInt
    
    /// Payment system
    let brand: String
    
    /// Credit card last 4 digits
    let last4: String
    
    /// Is this card selected as default one
    var isDefault: Bool = false
    
    init(id: String,
         expiryMonth: UInt,
         expiryYear: UInt,
         brand: String,
         last4: String)
    {
        self.id = id
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.brand = brand
        self.last4 = last4
    }
    
    /// Sets default card
    ///
    /// - Parameters:
    ///   - defaultId: Default Credit card ID
    ///   - cards: Array of user's credit cards
    /// - Returns: Array of user's credit cards
    /// - Throws: An error if there is no card with such id.
    static func set(defaultId: String?, in cards: [CreditCard]) throws -> [CreditCard] {
        guard let defaultId = defaultId else {
            if cards.isNotEmpty {
                throw "default card id is missing"
            }
            return cards
        }
        var output: [CreditCard] = []
        var defaultCardFound = false
        for card in cards {
            let isDefault = card.id == defaultId
            card.isDefault = isDefault
            if isDefault {
                if !defaultCardFound {
                    defaultCardFound = true
                    output.append(card)
                }
            } else {
                output.append(card)
            }
        }
        guard defaultCardFound || output.isEmpty else {
            throw "default card is missing for id \(defaultId)"
        }
        return output
    }
    
}

extension CreditCard: JSONAbleType {
    
    /// Decodes request
    ///
    /// - Parameter json: incoming JSON
    /// - Returns: Credit Card model
    /// - Throws: An error if reading fails, or if the data read is corrupted or otherwise invalid.
    static func from(json: JSON) throws -> CreditCard {
        let id = try json["id"].expectingString()
        let month = try json["exp_month"].expectingInt()
        let year = try json["exp_year"].expectingInt()
        let brand = try json["brand"].expectingString()
        let last4 = try json["last4"].expectingString()
        guard let uintMonth = UInt(exactly: month) else { throw "invalid expiration month" }
        guard let uintYear = UInt(exactly: year) else { throw "invalid expiration year" }
        return CreditCard(id: id,
                          expiryMonth: uintMonth,
                          expiryYear: uintYear,
                          brand: brand,
                          last4: last4)
    }
    
}

extension CreditCard {
    
    /// Precise credit card expiration date
    var expirationDate: Date {
        /// the card expires on the final day of the month the card is set to expire.
        let expirationMonth = expiryMonth + 1
        return DateComponents(calendar: .current,
                              year: Int(expiryYear),
                              month: Int(expirationMonth)).date!
    }
    
    /// Is credit card expired
    var isExpired: Bool {
        return expirationDate < Date()
    }
}

struct CreditCardInfo {
    let number: String
    let expiryMonth: UInt
    let expiryYear: UInt
    let cvv: String
    let zip: String
}
