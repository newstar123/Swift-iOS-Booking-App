//
//  Venue.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/2/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import IGListKit
import GoogleMaps

final class Venue: NSObject {
    
    /// Venue ID
    let venue_id: Int
    
    /// Venue location coordinate - latitude
    let locLatitude: Double?
    
    /// Venue location coordinate - longitude
    let locLongitude: Double?
    
    /// Checkout radius
    let checkOutRadius: Meters?
    
    /// Venue title
    let name: String
    
    /// Discount value
    let discount: Float?
    
    /// Venue's location ID
    let location_id: Int?
    
    /// Venue's neighborhood
    let neighborhood:String?
    
    /// Venue's city
    let city:String?
    
    /// Venue's state
    let state:String?
    
    /// Venue's zip code
    let zip:String?
    
    /// Venue's icon color
    let venue_type:String?
    
    /// Venue's POS type title, i.e. Aloha POS - only used for testing (via developer mode)
    let pos_type: String
    
    /// Venue's icon color
    let icon_color:String?
    
    /// Venue's primary image
    let main_photo_url:String?
    
    /// Venue's images
    let gallery_urls: [String]
    
    /// Venue's video presentation URL
    let video_url:String?
    
    /// Venue's video thumbnail URL
    let video_thumbnail_url:String?
    
    let uberEstimates: [UberEstimate]
    
    /// Venue's description
    let venue_description:String?
    
    /// Venue's address
    let address:String?
    
    /// Venue's website
    let website:String?
    
    /// Venue's email
    let email:String?
    
    /// Venue's slogan
    let slogan:String?
    
    /// Link to venue's twitter account
    let twitterHandle:String?
    
    /// price level
    let priceAvg: Int?
    
    /// visitors average age
    let patronAgeAvg: Int?
    
    /// Beacons assigned to the venue
    let beacons: [Beacon]
    
    /// returns false if beacon located nearby
    var beaconDetected: Bool
    
    /// Venues features
    let features: [Feature]
    
    /// Inside tips section features
    let insider_tips: [Feature]
    
    /// Opening hours
    let timeSlots: [TimeSlot]
    
    /// Kitchen opening hours
    let kitchenTimeSlots: [TimeSlot]
    
    /// Venue contact phone number
    let phone_number: String?
    
    /// Active Users checked in the venue
    let checkedInUsers: [Avatar]
    
    /// Additional Venue info
    let specialNotice: String?
    
    /// Uber discount
    let ridesafeDiscountValue: Int
    
    /// Background image for venue
    let backgroundImageUrl: String?
    
    /// True if Venue has been activated via admin dashboard
    let isActive: Bool?
    
    /// Belonging time zone
    let timeZone: TimeZone?
    
    lazy var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        return calendar
    }()
    
    enum Status {
        
        /// Venue is open
        case open(openedOn: Weekday, closesAt: Date)
        
        /// Venue will be closed soon
        case closesSoon(at: Date, openedOn: Weekday)
        
        /// Venue is closed but will be open soon
        case opensLater(at: Date)
        
        /// Venue is closed
        case closed
        
        /// Status date formatter
        static let indicatorDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter
        }()
        
        /// Status description
        var indicatorText: String {
            switch self {
            case .open(_, let closingDate), .closesSoon(let closingDate, _):
                let closingString = Status.indicatorDateFormatter.string(from: closingDate)
                return "Closes at \(closingString)"
            case .opensLater(let openingDate):
                let openingString = Status.indicatorDateFormatter.string(from: openingDate)
                return "Opens at \(openingString)"
            case .closed:
                return "Closed"
            }
        }
        
        /// Status label color
        var indicatorColor: UIColor {
            switch self {
            case .open: return UIColor(in8bit: 104, 190, 104)
            case .closesSoon: return UIColor(in8bit: 171, 104, 226)
            case .opensLater, .closed: return UIColor(in8bit: 204, 14, 19)
            }
        }
        
        /// Map marker color for venue status
        var mapMarkerColor: UIColor {
            switch self {
            case .open: return UIColor(in8bit: 0, 178, 222)
            case .closesSoon: return UIColor(in8bit: 171, 104, 226)
            case .opensLater, .closed: return UIColor(in8bit: 91, 96, 111)
            }
        }
        
    }
    
    /// Venue status for date
    ///
    /// - Parameter current: Current Date
    /// - Returns: Status instance
    func status(on current: Date = Date()) -> Status {
        if AppConfig.allVenuesAlwaysOpen {
            let now = Date()
            let dayInterval = Time(24, .hours)[in: .seconds]
            let tomorrow = now.addingTimeInterval(dayInterval)
            return .open(openedOn: Weekday(date: now), closesAt: tomorrow)
        }
        let previous = current.addingTimeInterval(-.dayInterval)
        let next = current.addingTimeInterval(.dayInterval)
        let dates = [previous, current, next]
        for date in dates {
            if  let thisSchedule = timeSlots.schedule(onDayOf: date,
                                                      calendar: calendar),
                let status = thisSchedule.status(at: current)
            {
                if  case .closesSoon(_, let openedDay) = status,
                    let nextSchedule = timeSlots.schedule(onDayOf: date.addingTimeInterval(.dayInterval),
                                                          calendar: calendar),
                    nextSchedule.opening <= thisSchedule.closing
                {
                    return .open(openedOn: openedDay, closesAt: nextSchedule.closing)
                }
                return status
            }
        }
        return .closed
    }
    
    /// Returns true if venue is open now
    var isOpen: Bool {
        switch status() {
        case .open, .closesSoon:
            return true
        case .opensLater, .closed:
            return false
        }
    }
    
    /// Returns array of Facebook friends checked in the venue
    var checkedInFriends: [Avatar] {
        return checkedInUsers.filter { $0.isFacebookFriend }
    }
    
    /// Returns currently checked in users that are eligible to display in "See who's here" section
    var checkedInUsersVisible: [Avatar] {
        let userId = User.stored.userId
        return checkedInUsers.filter { $0.isVisible && $0.avatarId != userId }
    }
    
    /// Distance to venue from patron
    var distance: Distance? {
        if let userLocation = LocationService.shared.location {
            let metersAmount = userLocation.distance(from: CLLocation(latitude: coordinate.latitude,
                                                                      longitude: coordinate.longitude))
            return Distance(metersAmount, .meters)
        }
        return nil
    }
    
    /// Venue coordinate
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(locLatitude ?? 0, locLongitude ?? 0)
    }
    
    /// returns number of miles to reach the venue
    /// expected to be convertible to `Double` in sorting
    var distanceString: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.1f", arguments: [distance[in: .miles]])
    }
    
    /// Human-readable distance string
    var distanceText: String {
        var distanceText = ""
        if let distanceString = distanceString {
            distanceText.append("\(distanceString) MILES")
        }
        if let neighborhood = neighborhood {
            if distanceText != "" {
                distanceText.append(" - ")
            }
            distanceText.append(neighborhood.uppercased())
        }
        return distanceText
    }
    
    /// Human-readable discount value string
    var discountValue: String {
        if let discount = discount, discount >= 0 {
            return String(format: "%.0f%@", arguments: [discount, NSLocalizedString("% OFF", comment: "")])
        }
        return "-"
    }
    
    /// Venue title without article
    var sortName: String {
        let thePrefix = "The "
        if name.hasPrefix(thePrefix) {
            return String(name.dropFirst(thePrefix.count))
        }
        return name
    }
    
    /// Venue type string
    /// In Developing mode POS title can be appended
    var venueTypeText: String {
        let venueType = venue_type?.uppercased() ?? ""
        guard AppConfig.displayPOSInfo else { return venueType }
        return "\(pos_type) - \(venueType)"
    }
    
    fileprivate init(venueIdentifier: Int) {
        self.venue_id = venueIdentifier
        self.locLatitude = .none
        self.locLongitude = .none
        self.checkOutRadius = .none
        self.name = ""
        self.discount = .none
        self.location_id = .none
        self.neighborhood = .none
        self.city = .none
        self.state = .none
        self.zip = .none
        self.venue_type = .none
        self.pos_type = ""
        self.icon_color = .none
        self.main_photo_url = .none
        self.gallery_urls = []
        self.video_url = .none
        self.video_thumbnail_url = .none
        self.uberEstimates = []
        self.venue_description = .none
        self.address = .none
        self.website = .none
        self.email = .none
        self.slogan = .none
        self.twitterHandle = .none
        self.priceAvg = .none
        self.patronAgeAvg = .none
        self.beacons = []
        self.beaconDetected = false
        self.features = []
        self.insider_tips = []
        self.timeSlots = []
        self.kitchenTimeSlots = []
        self.phone_number = .none
        self.checkedInUsers = []
        self.specialNotice = .none
        self.ridesafeDiscountValue = 15
        self.backgroundImageUrl = .none
        self.isActive = .none
        self.timeZone = nil
    }
    
    required convenience override init() {
        self.init(venueIdentifier: 0)
    }
    
    required init(
        venue_id: Int,
        locLatitude: Double?,
        locLongitude: Double?,
        checkOutRadius: Meters?,
        name: String,
        discount: Float?,
        location_id: Int?,
        neighborhood: String?,
        city: String?,
        state: String?,
        zip: String?,
        venue_type: String?,
        pos_type: String,
        icon_color: String?,
        main_photo_url: String?,
        gallery_urls: [String],
        video_url: String?,
        video_thumbnail_url: String?,
        uberEstimates: [UberEstimate] = [],
        venue_description: String?,
        address: String?,
        website: String?,
        email: String?,
        slogan: String?,
        twitterHandle: String?,
        priceAvg: Int?,
        patronAgeAvg: Int?,
         beacons: [Beacon],
        beaconDetected: Bool,
        currentlyCheckedInCached: Bool,
        features: [Feature],
        insider_tips: [Feature],
        timeSlots: [TimeSlot],
        kitchenTimeSlots: [TimeSlot],
        phone_number: String?,
        checkedInUsers: [Avatar],
        fbFriendCt: Int,
        specialNotice: String?,
        ridesafeDiscountValue: Int,
        backgroundImageUrl: String?,
        isActive: Bool?,
        timeZone: TimeZone?)
    {
        self.venue_id = venue_id
        self.locLatitude = locLatitude
        self.locLongitude = locLongitude
        self.checkOutRadius = checkOutRadius
        self.name = name
        self.discount = discount
        self.location_id = location_id
        self.neighborhood = neighborhood
        self.city = city
        self.state = state
        self.zip = zip
        self.venue_type = venue_type
        self.pos_type = pos_type
        self.icon_color = icon_color
        self.main_photo_url = main_photo_url
        self.gallery_urls = gallery_urls
        self.video_url = video_url
        self.video_thumbnail_url = video_thumbnail_url
        self.uberEstimates = uberEstimates
        self.venue_description = venue_description
        self.address = address
        self.website = website
        self.email = email
        self.slogan = slogan
        self.twitterHandle = twitterHandle
        self.priceAvg = priceAvg
        self.patronAgeAvg = patronAgeAvg
        self.beaconDetected = beaconDetected
        self.features = features
        self.insider_tips = insider_tips
        self.timeSlots = timeSlots
        self.kitchenTimeSlots = kitchenTimeSlots
        self.phone_number = phone_number
        self.checkedInUsers = checkedInUsers
        self.specialNotice = specialNotice
        self.ridesafeDiscountValue = ridesafeDiscountValue
        self.backgroundImageUrl = backgroundImageUrl
        self.beacons = beacons
        self.isActive = isActive
        self.timeZone = timeZone
    }
    
}

// MARK: - JSONAbleType
extension Venue: JSONAbleType {
    
    static func from(json: JSON) throws -> Venue {
        let venueId = try json["id"].expectingInt()
        
        let lat = json["latitude"].double
        let lon = json["longitude"].double
        let checkOutRadius = json["radius"].double
        let name = json["name"].stringValue
        var discountType = 0 as Float
        if let discount = json["current_discount"].float {
            discountType = discount
        } else if let discount = json["promo_discount"].float {
            discountType = discount
        } else if let base_discount = json["base_discount"].float {
            discountType = base_discount
        }
        let neighborhood = json["neighborhood"].string
        let zip = json["zip"].string
        let city = json["city"].string
        let state = json["state"].string
        let venue_type = json["type"].string
        let pos_type = json["vendorCurrentPosType"]["posType"]["pos_type"].string ?? "Unknown"
        let address = json["address"].string
        let venue_description = json["description"].string
        let slogan = json["slogan"].string
        let phone = json["phone"].string
        let website = json["website"].string
        let email = json["email"].string
        let twitterHandle = json["twitter_handle"].string
        let priceAvg = json["price_avg"].int
        let patronAgeAvg = json["patron_age_avg"].int
        var specialNotice = ""
        if  let notice = json["special_notice"].string,
            let approved = json["special_notice_status"].string,
            approved == "approved",
            notice.isNotEmpty {
            specialNotice = notice
            print(name, specialNotice)
        }
        let ridesafeDiscountValue = json["location"]["ridesafe_discount_value"].int
        let backgroundImageUrl = json["background_image_url"].string
        let locationId = json["location_id"].int
        
        var beacons: [Beacon] = []
        if let beaconUUID = json["beacon_id"].string {
            if let uuid = UUID(uuidString: beaconUUID) {
                let beacon = Beacon(uuid: uuid)
                beacons.append(beacon)
            }
        } else if let _beacons = try? Beacon.arrayFrom(json: json["gimbalBeacons"]) {
            beacons.append(contentsOf: _beacons)
        }
        
        let features = json["features"].arrayValue
            .compactMap { Feature.from(string: $0.string) }
        let insider_tips = json["insider_tips"].arrayValue
            .compactMap { Feature.from(string: $0.string) }
        var photos = json["image_urls"].arrayValue
            .compactMap { $0.string }
        if let url = backgroundImageUrl {
            photos.insert(url, at: 0)
        }
        
        let mainPhoto = photos.first
        let video_url = json["video_url"].string
        let video_thumb_url: String?
        if let thumbURL = json["video_thumb_url"].string {
            video_thumb_url = thumbURL
        } else if video_url.hasValue {
            video_thumb_url = mainPhoto
        } else {
            video_thumb_url = nil
        }
        let timeSlots = json["hours"].arrayValue
            .compactMap { TimeSlot.from(string: $0.string) }
        let kitchenTimeSlots = json["kitchen_hours"].arrayValue
            .compactMap { TimeSlot.from(string: $0.string) }
        let avatars = json["patronsWithOpenedCheckin"].arrayValue
            .compactMap { try? Avatar.from(json: $0) }
        let isActive = json["is_active"].boolValue
        let timezoneId = json["timezone"].stringValue
        let timeZone = TimeZone(identifier: timezoneId)
        
        return Venue.init(venue_id: venueId,
                          locLatitude: lat,
                          locLongitude: lon,
                          checkOutRadius: checkOutRadius,
                          name: name,
                          discount: discountType,
                          location_id: locationId,
                          neighborhood: neighborhood,
                          city: city,
                          state: state,
                          zip: zip,
                          venue_type: venue_type,
                          pos_type: pos_type,
                          icon_color: "",
                          main_photo_url: mainPhoto,
                          gallery_urls: photos,
                          video_url: video_url,
                          video_thumbnail_url: video_thumb_url,
                          venue_description: venue_description,
                          address: address,
                          website: website,
                          email: email,
                          slogan: slogan,
                          twitterHandle: twitterHandle,
                          priceAvg: priceAvg,
                          patronAgeAvg: patronAgeAvg,
                          beacons: beacons,
                          beaconDetected: false,
                          currentlyCheckedInCached: false,
                          features: features,
                          insider_tips: insider_tips,
                          timeSlots: timeSlots,
                          kitchenTimeSlots: kitchenTimeSlots,
                          phone_number: phone,
                          checkedInUsers: avatars,
                          fbFriendCt: 0,
                          specialNotice: specialNotice,
                          ridesafeDiscountValue: ridesafeDiscountValue ?? 0,
                          backgroundImageUrl: backgroundImageUrl,
                          isActive: isActive,
                          timeZone: timeZone)
    }
    
}

extension Venue {
    
    /// Returns true if current user's location is in checkin radius (appr. 250 meters)
    var isNearby: Bool {
        let tooFarToCheckIn = LocationService.shared.tooFarForCheckin(coordinate)
     
        return !tooFarToCheckIn
    }
    
    /// Returns true if user is currently checked in th Venue
    var isCheckedIn: Bool {
        var checkedIn = false
        if let hashedCheckin = AppDelegate.shared.checkinHash[venue_id], hashedCheckin.checkout_time == nil {
            checkedIn = true
        }
        
        return checkedIn
    }
    
    /// Returns Market for venue
    var market: VendorCity? {
        return CityManager.shared.cities.first(where: { $0.id == location_id} )
    }
    
    /// Returns number of male checked in
    var checkedInMaleCount: Int {
        return checkedInUsersVisible
            .filter { $0.gender == .male }
            .count
    }
    
    /// Returns number of female checked in
    var checkedInFemaleCount: Int {
        return checkedInUsersVisible
            .filter { $0.gender == .female }
            .count
    }

}

extension Array where Element: Venue {
    
    /// Returns true if venue with active checkin presents in given array
    var containsVenueWithOpenedTab: Bool {
        return contains(where: { $0.isCheckedIn })
    }
    
}

