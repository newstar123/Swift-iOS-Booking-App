//
//  Checkin.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/29/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Checkin: NSObject, Comparable {
    
    /// Checkin ID
    let checkin_id: Int // Required
    
    /// Checkin date
    var created = Date(timeIntervalSince1970: 0)
    
    /// Last checked date
    var last_seen: Date?
    
    /// Checkout date
    var checkout_time: Date?
    
    /// Returns true if checkout was initialized by server
    var autoClosed: Bool?
    
    /// User's feedback - if posted
    var feedback: String?
    
    /// Number of drinks required for discount
    var num_drinks: Int?
    
    ///
    var rounds: Int?
    
    /// User ID
    var patron_id: Int?
    
    /// Discount amount for Uber ride if available
    var uberDiscountValue: Int?
    
    /// Venue assigned with Checkin
    var venue: Venue?
    var rating: Int?
    
    /// Bill instance for Checkin
    var bill: Bill?
    
    /// Ridesafe instance, indicates free Uber ride status
    var ridesafeStatus: RidesafeStatus?
    
    var isOwner: Bool {
        return patron_id == User.stored.userId
    }
    
    var needsReview: Bool {
        return checkout_time != nil && rating == nil && autoClosed == false
    }
    
    fileprivate init(checkinIdentifier: Int) {
        self.checkin_id = checkinIdentifier
    }
    
    class func checkinWithCheckinId(_ checkinId:Int) -> Checkin {
        let appDelegate = AppDelegate.shared
        if let checkin = appDelegate.checkinHash[checkinId] {
            return checkin
        } else {
            let checkin = Checkin(checkinIdentifier: checkinId)
            appDelegate.checkinHash[checkinId] = checkin
            return checkin
        }
    }
    
    class func checkinWithVenueId(_ venueId:Int, checkinId: Int) -> Checkin {
        let appDelegate = AppDelegate.shared
        if let checkin = appDelegate.checkinHash[venueId], checkinId == checkin.checkin_id {
            return checkin
        } else {
            let checkin = Checkin(checkinIdentifier: checkinId)
            appDelegate.checkinHash[venueId] = checkin
            return checkin
        }
    }
    
    /// Represents status of ridesafe feature
    ///
    /// - enabled: ride safe feature is unlocked
    /// - waiting: patron haven't waited enough after reaching limit
    /// - disabled: ride safe isn't available for this venue, or patron haven't ordered for the ridesafe limit yet
    enum RideSafeData {
        case enabled(discount: Int)
        case waiting(timeLeft: Int)
        case disabled
    }
    
    var rideSafeData: RideSafeData {
        guard
            let uberDiscount = uberDiscountValue,
            uberDiscount > 0,
            let ridesafeStatus = ridesafeStatus else { return .disabled }
        if ridesafeStatus.isFreeRideAvailable {
            return .enabled(discount: uberDiscount)
        }
        guard let bill = bill else {
            return .disabled
        }
        
        let minSpendToRide = ridesafeStatus.minSpendToRide ?? 1
        let timeLeft = ridesafeStatus.timeLeft ?? 0
        let itemsOrdered = bill.items.count
        let alreadySpent = bill.totals.subTotal
        
        if minSpendToRide <= alreadySpent, itemsOrdered > 0, timeLeft > 0 {
            return .waiting(timeLeft: timeLeft)
        }
        return .disabled
    }
    
    /// Returns self, if freeRide availble, otherwise defaults to unused freeRide, if any
    /// If no freeRide available, returns nil
    var freeRideCheckin: Checkin? {
        if case .enabled = rideSafeData {
            return self
        }
        if let freeRideCheckin = AppDelegate.shared.freeRideCheckinsHash.first {
            if case .enabled = freeRideCheckin.rideSafeData {
                return freeRideCheckin
            }
        }
        return nil
    }
    
}

// MARK: - JSONAbleType
extension Checkin: JSONAbleType {
    
    static func from(json: JSON) throws -> Checkin {
        let checkinId = try json["id"].expectingInt()
        let venueId = try json["vendor_id"].expectingInt()
        let checkin = Checkin.checkinWithVenueId(venueId, checkinId: checkinId)
        
        if json["vendor_id"].int != nil  {
            let venue = try Venue.from(json: json["vendor"])
            checkin.venue = venue
        }
        
        if let created = json["created_at"].string {
            if let created_at = Date.standardDateFormatter.date(from: created) {
                checkin.created = created_at
            }
        }
        
        if let last_seen = json["last_seen"].string {
            checkin.last_seen = Date.standardDateFormatter.date(from: last_seen)
        }
        
        if let checkout_time = json["checkout_time"].string {
            checkin.checkout_time = Date.standardDateFormatter.date(from: checkout_time)
        }
        
        if let auto_closed = json["auto_closed"].bool {
            checkin.autoClosed = auto_closed
        }
        
        if let feedback = json["feedback"].string {
            checkin.feedback = feedback
        }
        
        if let num_drinks = json["num_drinks"].int {
            checkin.num_drinks = num_drinks
        }
        
        if let rating = json["rating"].int {
            checkin.rating = rating
        }
        
        if let patron_id = json["patron_id"].int {
            checkin.patron_id = patron_id
        }
        
        checkin.bill = try? Bill.from(json: json["billItems"])
        
        if let bill = checkin.bill {
            bill.totals = try BillTotals.from(json: json["totals"])
            
            if let discount = json["discount"].int {
                bill.discount = discount
            }
            if let gratuity = json["gratuity"].int {
                bill.gratuity = gratuity
            }
            if let exactGratuity = json["exact_gratuity"].int {
                bill.exactGratuity = exactGratuity
            }
        }
        
        checkin.ridesafeStatus = RidesafeStatus.safelyFrom(json: json["ridesafeDiscountStatus"])
        
        if let uberDiscount = json["rideDiscount"]["discount_value"].int {
            checkin.uberDiscountValue = uberDiscount
        }
        
        return checkin
    }

}
        

func <(lhs: Checkin, rhs: Checkin) -> Bool {
    return rhs.created.timeIntervalSince1970 < lhs.created.timeIntervalSince1970
}

func ==(lhs: Checkin, rhs: Checkin) -> Bool {
    return rhs.created.timeIntervalSince1970 == lhs.created.timeIntervalSince1970
}

