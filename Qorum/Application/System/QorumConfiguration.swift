//
//  QorumConfiguration.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/3/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

enum Environment: String {
    case staging = "staging"
    case production = "production"
    case demo = "demo"
    
    var baseURL: URL {
        switch self {
        case .staging: return URL(string: "https://qorum-backend-staging.herokuapp.com")!
        case .production: return URL(string: "http://qorum-backend.herokuapp.com")!
        case .demo: return URL(string: "http://qorum-backend-demo.herokuapp.com")!
        }
    }
    
    
}

class QorumConfiguration {
    lazy var environment: Environment = {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "QorumConfiguration") as? String {
            if configuration.range(of: "Staging") != nil {
                return Environment.staging
            } else if configuration.range(of: "Demo") != nil {
                return Environment.demo
            }
        }
        return Environment.production
    }()
}
