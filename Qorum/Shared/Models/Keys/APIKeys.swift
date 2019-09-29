//
//  APIKeys.swift
//  Botl
//
//  Created by Dmitriy Tsurkan on 2/21/17.
//  Copyright © 2017 Botl. All rights reserved.
//

import Foundation

private let minimumKeyLength = 2

// Mark: - API Keys
struct APIKeys {
    
    /// API Key
    let key: String
    
    /// API Secret
    let secret: String

    // MARK: Shared Keys
    
    fileprivate struct SharedKeys {
        static var instance = APIKeys()
    }
    
    static var sharedKeys: APIKeys {
        get {
            return SharedKeys.instance
        }
        
        set (newSharedKeys) {
            SharedKeys.instance = newSharedKeys
        }
    }

    // MARK: Methods
    
    var stubResponses: Bool {
        return key.count < minimumKeyLength || secret.count < minimumKeyLength
    }
    
    // MARK: Initializers
    init(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
    
    init(keys: QorumKeys) {
        self.init(key: keys.qorumAPIClientKey , secret: keys.qorumAPIClientSecret )
    }
    
    init() {
        let keys = QorumKeys()
        self.init(keys: keys)
    }
}
