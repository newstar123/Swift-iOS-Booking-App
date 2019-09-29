//
//  QorumDirectionsAPI.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/5/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import Moya

enum QorumDirectionsAPI {
    case directions(sensor: String, origin: String, destination: String, language: String, key: String)
}

// MARK: - QorumAPITarget
extension QorumDirectionsAPI: QorumAPITarget {
    
    var base: String { return "https://maps.googleapis.com" } // "https://api.uber.com"
    var baseURL: URL { return URL(string: base)! }
    
    var path: String {
        switch self {
        case .directions:
            return "/maps/api/directions/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .directions:
            return .get
        }
    }
    
    var task: Task {
        
        switch self {
        case .directions(let sensor,
                         let origin,
                         let destination,
                         let language,
                         let key):
            var params: [String: Any] = [:]
            params.updateValue(sensor, forKey: "sensor")
            params.updateValue(origin, forKey: "origin")
            params.updateValue(destination, forKey: "destination")
            params.updateValue(language, forKey: "language")
            if key.count > 0 {
                params.updateValue(key, forKey: "key")
            }
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
    }
    
}
