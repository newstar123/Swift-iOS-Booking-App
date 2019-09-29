//
//  FacebookAPI.swift
//  Qorum
//
//  Created by Stanislav on 24.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import FacebookCore
import SwiftyJSON
import Moya

// MARK: - GraphResponseProtocol
extension JSON: GraphResponseProtocol {
    
    public init(rawResponse: Any?) {
        self.init(rawResponse ?? NSNull())
    }
    
}

enum FacebookAPI: GraphRequestProtocol {
    case profile
    case friends
    case picture(maxSize: Int)
    
    typealias Response = JSON
    
    var graphPath: String {
        switch self {
        case .profile: return "me"
        case .friends: return "me/friends"
        case .picture: return "me"
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .profile: return ["fields": "id, email, picture, first_name, last_name, gender, birthday"]
        case .friends: return ["fields": "id, name"]
        case .picture(let maxSize): return ["fields": "picture.width(\(maxSize)).height(\(maxSize))"]
        }
    }
    
    var accessToken: AccessToken? {
        return AccessToken.current
    }
    
    var httpMethod: GraphRequestHTTPMethod {
        return GraphRequestHTTPMethod.GET
    }
    
    var apiVersion: GraphAPIVersion {
        return GraphAPIVersion.defaultVersion
    }
    
}

// MARK: - QorumEndpointDescriptor
extension FacebookAPI: QorumEndpointDescriptor {
    
    var method: Moya.Method {
        switch httpMethod {
        case .GET:
            return .get
        case .POST:
            return .post
        case .DELETE:
            return .delete
        }
    }
    
    var path: String {
        return "facebook-graph/\(graphPath)"
    }
    
}
