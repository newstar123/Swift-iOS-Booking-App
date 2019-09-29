//
//  Bill.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/29/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BillItem {
    
    /// Bill item ID
    var id: Int = 0
    
    /// Checkin ID assosiated with Bill
    var checkinId: Int = 0
    
    /// Omnivore ticket ID
    var omnivoreTicketItemId: String?
    
    /// Updated Date
    var updated: Date?
    
    /// Created Date
    var created: Date?
    
    /// Bill item title
    var name: String?
    
    /// Bill item description
    var description: String?
    
    /// Quantity
    var quantity: Int = 0
    
    /// Price for unit
    var unitPrice: Int = 0
    
    /// Total amount
    var totalPrice: Int {
        return unitPrice * quantity
    }
}

protocol Mergable {
    
    func isMergable(with: Self) -> Bool
    
    mutating func merge(with item: Self) throws
    
    func merged(with item: Self) throws -> Self
}

extension BillItem: Mergable {
    
    func isMergable(with item: BillItem) -> Bool {
        return name == item.name && unitPrice == item.unitPrice
    }
    
    mutating func merge(with item: BillItem) throws {
        guard name == item.name else {
            throw NSError(domain: "Unsatisfied candidate for merge", code: -1, userInfo: [
                "originalName" : self.name as Any,
                "candidateName" : item.name as Any
            ])
        }
        guard unitPrice == item.unitPrice else {
            throw NSError(domain: "Unsatisfied candidate for merge", code: -1, userInfo: [
                "originalUnitPrice" : self.unitPrice as Any,
                "candidateUnitPrice" : item.unitPrice as Any
            ])
        }
        quantity += item.quantity
    }
    
    func merged(with item: BillItem) throws -> BillItem {
        var copy = item
        try copy.merge(with: item)
        return copy
    }
    
}

final class BillTotals {
    
    /// Tax amount
    var tax: Int = 0
    
    /// Approximate tax amount
    var approximateTax: Int = 0
    
    /// Subtotal amount
    var subTotal: Int = 0
    
    /// Service cherge amount
    var serviceCharges: Int = 0
    
    /// Due amount
    var due: Int = 0
    
    /// Other charge amount
    var otherCharges: Int = 0
    
    /// Number of free drinks, excluded from Bill
    var freeDrinks: Int = 0
    
    /// Total amount for free drinks excluded from Bill
    var freeDrinksPrice: Int = 0
    
    /// Total amount
    var total: Int = 0
}

// MARK: - SafeJSONAbleType
extension BillTotals: SafeJSONAbleType {
    
    static var placeholder: BillTotals {
        return BillTotals()
    }
    
    static func from(json: JSON) throws -> BillTotals {
        let billTotals = BillTotals()
        billTotals.tax = json["tax"].intValue
        billTotals.approximateTax = json["approximateTax"].intValue
        billTotals.subTotal = json["sub_total"].intValue
        billTotals.serviceCharges = json["service_charges"].intValue
        billTotals.due = json["due"].intValue
        billTotals.otherCharges = json["other_charges"].intValue
        billTotals.total = json["total"].intValue
        billTotals.freeDrinks = json["num_free_drinks_used"].intValue
        billTotals.freeDrinksPrice = json["freedrinks_discount"].intValue
        return billTotals
    }
}

final class Bill {
    
    /// Bill items
    var items: [BillItem] = []
    
    /// Bill totals instance
    var totals: BillTotals = BillTotals()
    
    /// Tips in percent
    var gratuity: Int = 0 // percent
    
    /// Tips amount, precise value
    var exactGratuity: Int? //dollars
    
    /// Discount amount
    var discount: Int = 0 // percent
    
    /// Tax amount
    var tax: Double             { return totals.subTotal == 0 ? 0 : 100 * Double(totals.tax) / Double(totals.subTotal) }
    
    /// Items total price
    var itemsPrice: Int         { return totals.subTotal }
    
    /// Taxes approximate amount
    var taxPrice: Int           { return totals.approximateTax }
    
    /// Tips amount
    var gratuityPrice: Int      { return (exactGratuity ?? 0) > 0 ? (exactGratuity ?? 0) : ((totals.subTotal + totals.freeDrinksPrice) * gratuity + 50) / 100 }
    
    /// Discount amount
    var discountPrice: Int      { return (totals.subTotal * discount + 50) / 100 }
    
    /// Total Amount
    var totalPrice: Int         { return totals.subTotal - discountPrice + gratuityPrice + taxPrice }
    
    /// Returns true if there are no items in the Bill or has zero total amount
    var isEmpty: Bool {
        let isItemsEmpty = items.isEmpty
        let isSubtotalEmpty = totals.subTotal == 0
        return isItemsEmpty || isSubtotalEmpty
    }
    
}

// MARK: - SafeJSONAbleType
extension Bill: SafeJSONAbleType {
    
    static var placeholder: Bill {
        return Bill()
    }
    
    static func from(json: JSON) throws -> Bill {
        let bill = Bill()
        for (_, item_json) : (String, JSON) in json {
            var item = BillItem()
            item.name = item_json["name"].string
            item.description = item_json["description"].string
            item.quantity = item_json["quantity"].intValue
            item.unitPrice = item_json["price_per_unit"].intValue
            item.id = item_json["id"].intValue
            item.checkinId = item_json["checkin_id"].intValue
            item.omnivoreTicketItemId = item_json["omnivore_ticket_item_id"].string
            item.created = Date.standardDateFormatter.date(from: item_json["created_at"].stringValue)
            item.updated = Date.standardDateFormatter.date(from: item_json["updated_at"].stringValue)
            bill.items.append(item)
        }
        return bill
    }
    
}

extension Bill {
    var discountValue: String {
        if discount > 0 {
            return "\(discount)\(NSLocalizedString("% OFF", comment: ""))"
        }
        return "-"
    }
}
