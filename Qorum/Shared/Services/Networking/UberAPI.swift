//
//  UberAPI.swift
//  Qorum
//
//  Created by Stanislav on 13.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import Moya

enum UberAPI {
    case products(location: CLLocationCoordinate2D)
    case estimate(productId: String, seatsCount: Int?, startLocation: CLLocationCoordinate2D, finishLocation: CLLocationCoordinate2D)
    case orderUber(uberData: UberRequestData)
    case cancelUber(requestId: String)
    case estimatePrice(startLocation: CLLocationCoordinate2D, finishLocation: CLLocationCoordinate2D)
    case payments()
}

// MARK: - QorumAPITarget
extension UberAPI: QorumAPITarget {
    
    var baseUberURL: String { return AppConfig.uberSandboxModeEnabled ? "https://sandbox-api.uber.com" : "https://api.uber.com" }
    
    var baseURL: URL {
        return URL(string: baseUberURL)!
    }
    
    var path: String {
        switch self {
        case .products:
            return "/v1.2/products"
        case .estimate:
            return "/v1.2/requests/estimate"
        case .orderUber:
            return "/v1.2/requests"
        case .cancelUber(let requestId):
            return "/v1.2/requests/\(requestId)"
        case .estimatePrice:
            return "/v1.2/estimates/price"
        case .payments:
            return "/v1.2/payment-methods"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .products, .estimatePrice, .payments:
            return .get
        case .estimate, .orderUber:
            return .post
        case .cancelUber:
            return .delete
        }
    }
    
    var task: Task {
        let parameters: [String: Any]
        switch self {
        case .products(let location):
            var params: [String:Any] = [:]
            params["latitude"] = location.latitude
            params["longitude"] = location.longitude
            parameters = params
        case .estimate(let productId, let seatsCount, let startLocation, let finishLocation):
            var params: [String:Any] = [:]
            params["product_id"] = productId
            params["start_latitude"] = String(describing: startLocation.latitude)
            params["start_longitude"] = String(describing: startLocation.longitude)
            params["end_latitude"] = String(describing: finishLocation.latitude)
            params["end_longitude"] = String(describing: finishLocation.longitude)
            if let count = seatsCount {
                params["seat_count"] = count
            }
            parameters = params
        case .orderUber(let uberData):
            var params: [String:Any] = [:]
            params["start_latitude"] = uberData.pickup!.latitude
            params["start_longitude"] = uberData.pickup!.longitude
            params["end_latitude"] = uberData.dropoff!.latitude
            params["end_longitude"] = uberData.dropoff!.longitude
            if let pickupAddress = uberData.pickupAddress {
                params["start_address"] = pickupAddress
            }
            if let dropAddress = uberData.dropoffAddress {
                params["end_address"] = dropAddress
            }
            
            params["fare_id"] = uberData.type!.estimate!.fareId
            params["product_id"] = uberData.type!.productData?.product_id
            if let seatsCount = uberData.seatsCount {
                params["seat_count"] = seatsCount
            }
            if let surge = uberData.surgeConfirmationId {
                params["surge_confirmation_id"] = surge
            }
            if let defaultPayment = UserDefaults.standard.string(forKey: UserDefaultsKeys.defaultUberPaymentKey.rawValue) {
                params["payment_method_id"] = defaultPayment
            }
            
            parameters = params
        case .estimatePrice(let startLocation, let finishLocation):
            var params: [String:Any] = [:]
            params["start_latitude"] = startLocation.latitude
            params["start_longitude"] = startLocation.longitude
            params["end_latitude"] = finishLocation.latitude
            params["end_longitude"] = finishLocation.longitude
            parameters = params
        case .cancelUber, .payments:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding
        switch self {
        case .products, .estimatePrice, .payments:
            encoding = URLEncoding.default
        case .estimate, .orderUber, .cancelUber:
            encoding = JSONEncoding.default
        }
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        switch self {
        case .products, .estimate, .orderUber, .cancelUber, .payments:
            var token = ""
            if let uberToken = User.stored.settings.uber_token, uberToken.isNotEmpty {
                token = String(format: "Bearer %@", uberToken)
            }
            return ["Authorization": token]
        case .estimatePrice:
            let token = String(format: "Token %@", SocialServiceKeys.qorumUberServerTokenKey)
            return ["Authorization": token]
        }
    }
    
}




