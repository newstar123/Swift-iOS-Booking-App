//
//  Advertisement.swift
//  Qorum
//
//  Created by Stanislav on 21.05.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

struct AdvertisementData {
    
    /// Opened Tab Ad Image URL
    let myTabPhotoLink: String?
    
    /// Ad Image URL for Tab Closed Screen with Free Ride
    let tabClosedEligiblePhotoLink: String?
    
    /// Ad Image URL for Tab Closed Screen - Free Ride is Unavailable
    let tabClosedNotEligiblePhotoLink: String?
    
    /// Uber - Free Ride to Venue Ad Image URL
    let uberToBarPhotoLink: String?
    
    /// Uber - Free Ride from Venue Ad Image URL
    let uberFromBarEligiblePhotoLink: String?
    
    /// Uber - Free Ride from Venue is Unavailable Ad Image URL
    let uberFromBarNotEligiblePhotoLink: String?
    
    /// Uber - Free Ride to Venue Ad Video URL
    let uberToBarVideoLink: String?

    /// Uber - Free Ride from Venue Ad Video URL
    let uberFromBarEligibleVideoLink: String?

    /// Uber - Free Ride from Venue is Unavailable Ad Video URL
    let uberFromBarNotEligibleVideoLink: String?
    
    
    /// Ad URLs array
    var photoURLs: [URL] {
        let links = [myTabPhotoLink,
                     tabClosedEligiblePhotoLink,
                     tabClosedNotEligiblePhotoLink,
                     uberToBarPhotoLink,
                     uberFromBarEligiblePhotoLink,
                     uberFromBarNotEligiblePhotoLink]
        let urls = links.compactMap { $0?.url }
        return Array(Set(urls)) // return unique urls
    }
    
    /// Saves Ad URLs to UserDefaults
    func save() {
        let defaults = UserDefaults.standard
        defaults.advertMyTabPhotoURL = myTabPhotoLink?.url
        
        defaults.advertTabClosedEligiblePhotoURL = tabClosedEligiblePhotoLink?.url
        defaults.advertTabClosedNotEligiblePhotoURL = tabClosedNotEligiblePhotoLink?.url
        
        defaults.advertUberToBarPhotoURL = uberToBarPhotoLink?.url
        
        defaults.advertUberFromBarEligiblePhotoURL = uberFromBarEligiblePhotoLink?.url
        defaults.advertUberFromBarNotEligiblePhotoURL = uberFromBarNotEligiblePhotoLink?.url
        
        SDWebImagePrefetcher.shared().prefetchURLs(photoURLs)
        
        defaults.advertUberToBarVideoURL = uberToBarVideoLink?.url
        defaults.advertUberFromBarEligibleVideoURL = uberFromBarEligibleVideoLink?.url
        defaults.advertUberFromBarNotEligibleVideoURL = uberFromBarNotEligibleVideoLink?.url
    }
    
}

// MARK: - JSONAbleType
extension AdvertisementData: JSONAbleType {
    
    static func from(json: JSON) throws -> AdvertisementData {
        let attr = json["attributes"]
        let defaultImageLink = attr["image_url"].string
        let myTabPhotoLink = attr["my_tab_screen"].string ?? defaultImageLink
        let tabClosedEligiblePhotoLink = attr["tab_closed_eligible"].string
        let tabClosedNotEligiblePhotoLink = attr["tab_closed_not_eligible"].string
        let uberToBarPhotoLink = attr["uber_to_the_bar"].string ?? defaultImageLink
        let uberFromBarEligiblePhotoLink = attr["uber_from_the_bar_eligible"].string ?? defaultImageLink
        let uberFromBarNotEligiblePhotoLink = attr["uber_from_the_bar_not_eligible"].string ?? defaultImageLink
        let uberToBarVideoLink = attr["video_url"].string
        let uberFromBarEligibleVideoLink = attr["video_url3"].string
        let uberFromBarNotEligibleVideoLink = attr["video_url2"].string
        let advert = AdvertisementData(myTabPhotoLink: myTabPhotoLink,
                                       tabClosedEligiblePhotoLink: tabClosedEligiblePhotoLink,
                                       tabClosedNotEligiblePhotoLink: tabClosedNotEligiblePhotoLink,
                                       uberToBarPhotoLink: uberToBarPhotoLink,
                                       uberFromBarEligiblePhotoLink: uberFromBarEligiblePhotoLink,
                                       uberFromBarNotEligiblePhotoLink: uberFromBarNotEligiblePhotoLink,
                                       uberToBarVideoLink: uberToBarVideoLink,
                                       uberFromBarEligibleVideoLink: uberFromBarEligibleVideoLink,
                                       uberFromBarNotEligibleVideoLink: uberFromBarNotEligibleVideoLink)
        return advert
    }
    
}

// MARK: -

extension UserDefaults {
    
    var advertTabPhotoURL: URL? {
        return advertMyTabPhotoURL
    }
    
    func advertTabClosedPhotoURL(freeRide: Bool) -> URL? {
        if freeRide {
            return advertTabClosedEligiblePhotoURL
        }
        return advertTabClosedNotEligiblePhotoURL
    }
    
    func advertUberPhotoURL(rideFromVenue: Bool, freeRide: Bool) -> URL? {
        if freeRide {
            return advertUberFromBarEligiblePhotoURL
        }
        if rideFromVenue {
            return advertUberFromBarNotEligiblePhotoURL
        }
        return advertUberToBarPhotoURL
    }
    
    func advertUberVideoURL(rideFromVenue: Bool, freeRide: Bool) -> URL? {
        if freeRide {
            return advertUberFromBarEligibleVideoURL
        }
        if rideFromVenue {
            return advertUberFromBarNotEligibleVideoURL
        }
        return advertUberToBarVideoURL
    }
    
}

fileprivate extension UserDefaults {
    
    var advertMyTabPhotoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertTabClosedEligiblePhotoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertTabClosedNotEligiblePhotoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertUberToBarPhotoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertUberFromBarEligiblePhotoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertUberFromBarNotEligiblePhotoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertUberToBarVideoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertUberFromBarEligibleVideoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    var advertUberFromBarNotEligibleVideoURL: URL? {
        get { return url(forKey: #function) }
        set { setOrRemove(newValue, forKey: #function) }
    }
    
    func setOrRemove(_ url: URL?, forKey key: String) {
        guard let newURL = url else {
            removeObject(forKey: key)
            return
        }
        set(newURL, forKey: key)
    }
    
}

