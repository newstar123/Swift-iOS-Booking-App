//
//  QorumAuthenticatedAPI.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import Moya

protocol QorumAuthenticatedAPITarget: QorumAPITarget {
    
}

extension QorumAuthenticatedAPITarget {
    
    var headers: [String: String]? {
        return AppToken.headers
    }
    
}

enum QorumAuthenticatedAPI {
    case registerUser(params: [String: Any])
    case fetchUser(id: Int)
    case updateUser(id: Int, parameters: [String: Any])
    case updateDeviceToken(token: String, userId: Int)
    case addPaymentCard(userId: Int, stripeToken: String, zip: String)
    case fetchCreditCards(userId: Int)
    case setDefaultCreditCard(cardId: String, userId: Int)
    case deleteCreditCard(cardId: String, userId: Int)
    case openCheckin(userId: Int, venueId: Int)
    case checkout(userId: Int, checkinId: Int)
    case delayedCheckOut(userId: Int, checkinId: Int, delayMinutes: Int?)
    case cancelDelayedCheckOut(userId: Int, checkinId: Int)
    case updateCheckin(userId: Int, checkinId: Int)
    case updateVisibility(userId: Int, state: String)
    case fetchLastCheckins(userId: Int)
    case updateGratuityRate(checkinId: Int, percents: Int)
    case updateExactGratuity(checkinId: Int, cents: Int)
    case fetchCheckinsWithFreeRide(userId: Int)
}

// MARK: - QorumAPITarget
extension QorumAuthenticatedAPI: QorumAuthenticatedAPITarget {
    
    var baseURL: URL { return AppConfig.environment.url }
    
    var path: String {
        switch self {
        case .registerUser:
            return "/api/v2/patrons"
        case .fetchUser(let id), .updateUser(let id, _):
            return "/api/v2/patrons/\(id)"
        case .updateDeviceToken(_, let userId):
            return "/api/v2/patrons/\(userId)/device-token"
        case .addPaymentCard(let userId, _, _),
             .fetchCreditCards(let userId),
             .setDefaultCreditCard(_, let userId):
            return "/api/v2/patrons/\(userId)/cc"
        case .deleteCreditCard(let cardId, let userId):
            return "/api/v2/patrons/\(userId)/cc/\(cardId)"
        case .openCheckin(let userId, _):
            return "/api/v2/patrons/\(userId)/checkins"
        case .checkout(let userId, let checkinId):
            return "/api/v2/patrons/\(userId)/checkins/\(checkinId)/checkout"
        case .delayedCheckOut(let userId, let checkinId, let delay):
            var path = "/api/v2/patrons/\(userId)/checkins/\(checkinId)/delay"
            if let delay = delay {
                let minutesDelay = Double(delay)
                let millisecondsDelay = Int(Time(minutesDelay, .minutes)[in: .milliseconds])
                path.append("?ms=\(millisecondsDelay)")
            }
            return path
        case .cancelDelayedCheckOut(let userId, let checkinId):
            return "/api/v2/patrons/\(userId)/checkins/\(checkinId)/delay"
        case .updateCheckin(let userId, let checkinId):
            return "/api/v2/patrons/\(userId)/checkins/\(checkinId)"
        case .updateVisibility(let userId, _):
            return "/api/v2/patrons/\(userId)/fb_visible"
        case .fetchLastCheckins(let userId):
            return "/api/v2/patrons/\(userId)/checkins"
        case .updateGratuityRate(let checkin_id, _), .updateExactGratuity(let checkin_id, _):
            return "/api/v2/patrons/\(User.stored.userId)/checkins/\(checkin_id)/gratuity"
        case .fetchCheckinsWithFreeRide(let userId):
            return "/api/v2/patrons/\(userId)/checkins/ride_discount/idle"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .registerUser:
            return .post
        case .fetchUser:
            return .get
        case .updateUser:
            return .put
        case .updateDeviceToken:
            return .put
        case .addPaymentCard:
            return .post
        case .fetchCreditCards:
            return .get
        case .setDefaultCreditCard:
            return .put
        case .deleteCreditCard:
            return .delete
        case .openCheckin:
            return .post
        case .checkout:
            return .put
        case .delayedCheckOut:
            return .post
        case .cancelDelayedCheckOut:
            return .delete
        case .updateCheckin:
            return .get
        case .updateVisibility:
            return .put
        case .fetchLastCheckins:
            return .get
        case .updateGratuityRate, .updateExactGratuity:
            return .put
        case .fetchCheckinsWithFreeRide:
            return .get
        }
    }
    
    var task: Task {
        let parameters: [String: Any]
        switch self {
        case let .updateUser(_, params):
            parameters = params
        case let .updateDeviceToken(token,_):
            var params: [String : Any] = [:]
            params["mobile_platform"] = "ios"
            params["mobile_id"] = token
            parameters = params
        case let .registerUser(params):
            parameters = params
        case let .addPaymentCard(_, stripeToken, zip):
            parameters = ["token": stripeToken, "zip": zip]
        case let .setDefaultCreditCard(cardId, _):
            parameters = ["id": cardId]
        case let .openCheckin(_, venueId):
            parameters = ["vendor_id": venueId]
        case .updateVisibility(_, let state):
            parameters = ["facebook_visible": state]
        case .fetchLastCheckins:
            parameters = ["recent": 1]
        case .updateGratuityRate(_, let percents):
            parameters = ["gratuity": percents]
        case .updateExactGratuity(_, let cents):
            parameters = ["exact_gratuity": cents]
        default:
            parameters = [:]
        }
        let encoding: ParameterEncoding
        switch self {
        case .registerUser, .fetchUser:
            encoding = URLEncoding.default
        case .openCheckin, .updateVisibility:
            encoding = JSONEncoding.default
        default:
            encoding = URLEncoding.default
        }
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
