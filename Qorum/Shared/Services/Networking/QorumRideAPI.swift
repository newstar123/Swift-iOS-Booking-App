//
//  QorumRideAPI.swift
//  Qorum
//
//  Created by Stanislav on 13.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import Moya

enum QorumRideAPI {
    case registerUberToken(authCode: String, userId: Int)
    case registerRide(userId: Int, requestId: String, uberData: UberRequestData)
    case checkRidePromo(userId: Int, checkinId: Int)
    case applyRidePromo(userId: Int, rideId: String, checkinId: Int)
}

// MARK: - QorumAPITarget
extension QorumRideAPI: QorumAuthenticatedAPITarget {
    
    var path: String {
        switch self {
        case .registerUberToken(_, let userId):
            return "/api/v2/patrons/\(userId)/ride_token/uber"
        case .registerRide(let userId, _, _):
            return "/api/v2/patrons/\(userId)/rides/uber"
        case .checkRidePromo(let userId, let checkinId):
            return "/api/v2/patrons/\(userId)/checkins/\(checkinId)/uber/ride_promo"
        case .applyRidePromo(let userId, let rideId, let checkinId):
            return "/api/v2/patrons/\(userId)/checkins/\(checkinId)/uber/\(rideId)/ride_promo"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .checkRidePromo:
            return .get
        case .registerUberToken, .registerRide:
            return .post
        case .applyRidePromo:
            return .put
        }
    }
    
    var task: Task {
        let parameters: [String: Any]
        switch self {
        case .registerUberToken(let authCode, _):
            parameters = ["code": authCode]
        case .registerRide(_, let requestId, let uberData):
            var params: [String: Any] = [:]
            var rideType: String
            switch uberData.qorumRideType! {
            case .from:
                rideType = "from_bar"
            case .to:
                rideType = "to_bar"
            case .free:
                rideType = "free_ride"
            } 
            params["request_id"] = requestId
            params["ride_type"] = rideType
            params["start_latitude"] = uberData.pickup!.latitude
            params["start_longitude"] = uberData.pickup!.longitude
            params["destination_latitude"] = uberData.dropoff!.latitude
            params["destination_longitude"] = uberData.dropoff!.longitude
            parameters = params
        case .checkRidePromo, .applyRidePromo:
            parameters = [:]
        }
        
        let encoding = URLEncoding.default
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}

