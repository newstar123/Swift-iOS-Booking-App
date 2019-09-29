//
//  ITunesConnectionAPI.swift
//  Qorum
//
//  Created by Sergiy Kostrykin on 11/1/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import Moya

enum ITunesConnectionAPI {
    case lookup(id: String)
}

// MARK: - QorumAPITarget
extension ITunesConnectionAPI: QorumAPITarget {
    
    var base: String { return "https://itunes.apple.com" }
    var baseURL: URL { return URL(string: base)! }
    
    var path: String {
        switch self {
        case .lookup(let id):
            return "/lookup?bundleId=\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .lookup:
            return .get
        }
    }
    
    var task: Task {
        let parameters: [String: Any]
        switch self {
        case .lookup:
            parameters = [:]
        }
        
        let encoding: ParameterEncoding
        switch self {
        case .lookup:
            encoding = URLEncoding.default
        }
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
}
