//
//  QorumVenuesAPI.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/1/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import Moya
import CoreLocation

enum QorumVenuesAPI {
    case fetchVenuesForLocation(CLLocationCoordinate2D, radius: Distance)
    case fetchVenuesForCity(cityId: Int)
    case fetchVenue(id: Int)
    case fetchMenu(venueId: Int)
    case fetchAdvert
    case leaveReview(userId: Int, checkinId: Int, rating: Int, numDrinks: Int, feedback: String)
    case fetchBeacons(venueId: Int)
}

// MARK: - QorumAPITarget
extension QorumVenuesAPI: QorumAPITarget {
    
    var path: String {
        switch self {
        case .fetchVenuesForLocation:
            return "/api/v2/vendors/"
        case .fetchVenuesForCity(let cityId):
            return "/api/v2/locations/\(cityId)/vendors"
        case .fetchVenue(let id):
            return "/api/v2/vendors/\(id)"
        case .fetchMenu(let venueId):
            return "/api/v2/vendors/\(venueId)/menu"
        case .fetchAdvert:
            return "/api/v2/adverts/ridesafe"
        case .leaveReview(let userId, let checkinId, _, _, _):
            return "/api/v2/patrons/\(userId)/checkins/\(checkinId)/review"
        case .fetchBeacons(let venueId):
            return "/api/v2/vendors/\(venueId)/beacons"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchVenuesForLocation,
             .fetchVenuesForCity,
             .fetchVenue,
             .fetchMenu,
             .fetchAdvert,
             .fetchBeacons: return .get
        case .leaveReview: return .put
        }
    }
    
    var task: Task {
        switch self {
        case .fetchVenuesForLocation(let coordinate, let radius):
            var params: [String: Any] = ["range_miles": radius[in: .miles]]
            params["lat"] = coordinate.latitude
            params["lng"] = coordinate.longitude
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .leaveReview(_, _, let rating, let numDrinks, let feedback):
            var params: [String:Any] = [:]
            params["rating"] = rating
            params["num_drinks"] = numDrinks
            params["feedback"] = feedback
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .fetchVenuesForCity,
             .fetchVenue,
             .fetchMenu,
             .fetchAdvert,
             .fetchBeacons: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchVenuesForLocation,
             .fetchVenuesForCity,
             .fetchVenue,
             .fetchMenu,
             .fetchAdvert: return [:]
        case .fetchBeacons,
             .leaveReview: return AppToken.headers
        }
    }
    
}
