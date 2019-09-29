//
//  QorumAPI.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import SwiftyJSON

protocol QorumAPIHeaderType {
    var headers: [String: String]? { get }
}

protocol QorumEndpointDescriptor {
    var method: Moya.Method { get }
    var path: String { get }
}

extension QorumEndpointDescriptor {
    
    var endpointDescription: String {
        return "\(method.rawValue) \(path)"
    }
    
}

protocol QorumAPITarget: TargetType, QorumAPIHeaderType, QorumEndpointDescriptor, DecodingRequest {
    
}

extension QorumAPITarget {
    
    var request: QorumRequest<Self> {
        return QorumRequest<Self>(target: self)
    }
    
    func perform(completion: @escaping (APIResponse<JSON>) -> ()) {
        request.perform(completion: completion)
    }
    
    var baseURL: URL { return AppConfig.environment.url }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
}

enum QorumAPI {
    case socialAuth(accessToken: String)
    case fetchMetadata
    case locations
    case marketRadius
    case submitEmail(email: String, longitude: Double, latitude: Double, radius: Double)
}

// MARK: - QorumAPITarget
extension QorumAPI: QorumAPITarget {
    
    var path: String {
        switch self {
        case .socialAuth:
            return "/api/v2/patron"
        case .fetchMetadata:
            return "/api/v2/metadata"
        case .locations:
            return "/api/v2/locations"
        case .marketRadius:
            return "/api/v2/locations/demand/radius"
        case .submitEmail:
            return "/api/v2/locations/demand"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .socialAuth,
             .submitEmail: return .post
        case .locations,
             .marketRadius,
             .fetchMetadata: return .get
        }
    }
    
    var task: Task {
        switch self {
        case .socialAuth(let accessToken):
            return .requestParameters(parameters: ["facebook_token": accessToken],
                                      encoding: JSONEncoding.default)
        case .submitEmail(let email, let longitude, let latitude, let radius):
            return .requestParameters(parameters: ["email": email, "longitude": longitude, "latitude": latitude, "radius": radius],
                                      encoding: JSONEncoding.default)
        case .locations,
             .marketRadius,
             .fetchMetadata: return .requestPlain
        }
    }
    
}

extension MoyaProvider where Target: QorumAPIHeaderType {
    
    static var headerTypeProvider: MoyaProvider {
        let endpointClosure = { (target: Target) -> Endpoint in
            let endpoint = Endpoint(url: target.baseURL.absoluteString + target.path,
                                    sampleResponseClosure:  { .networkResponse(200, target.sampleData) },
                                    method: target.method,
                                    task: target.task,
                                    httpHeaderFields: target.headers)
            return endpoint
        }
        var plugins: [PluginType] = []
        if case let .enabled(verbose, cURL) = kNetworkingDebugBehaviour {
            plugins.append(NetworkLoggerPlugin(verbose: verbose, cURL: cURL))
        }
        return MoyaProvider(endpointClosure: endpointClosure, plugins: plugins)
    }
    
}

