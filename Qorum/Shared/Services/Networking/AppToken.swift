//
//  AppToken.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

private extension Date {
    var isInPast: Bool {
        let now = Date()
        return self.compare(now) == ComparisonResult.orderedAscending
    }
}

enum AppToken {
    
    enum DefaultsKeys: String {
        case TokenKey
        case RefreshToken
    }
    
    static var defaults: UserDefaults = .standard
    
    // MARK: - Properties
    
    static var headers: [String: String] {
        var tokenString = ""
        if let appToken = token {
            tokenString = "Bearer \(appToken)"
        }
        return ["Authorization": tokenString]
    }
    
    static var token: String? {
        get {
            return defaults.string(forKey: DefaultsKeys.TokenKey.rawValue)
        }
        set(newToken) {
            defaults.set(newToken, forKey: DefaultsKeys.TokenKey.rawValue)
        }
    }
    
    static var refreshToken: String? {
        get {
            let key = defaults.string(forKey: DefaultsKeys.RefreshToken.rawValue)
            return key
        }
        set(newToken) {
            defaults.set(newToken, forKey: DefaultsKeys.RefreshToken.rawValue)
        }
    }
    
    static var expiry: Date? {
        get {
            return defaults.object(forKey: DefaultsKeys.RefreshToken.rawValue) as? Date
        }
        set(newExpiry) {
            defaults.set(newExpiry, forKey: DefaultsKeys.RefreshToken.rawValue)
        }
    }
    
    static var isExpired: Bool {
        if let expiry = expiry {
            return expiry.isInPast
        }
        return true
    }
    
    static var isValid: Bool {
        if let token = token {
            return token.isNotEmpty && !isExpired
        }
        return false
    }
    
    static func remove() {
        defaults.removeObject(forKey: DefaultsKeys.TokenKey.rawValue)
        defaults.removeObject(forKey: DefaultsKeys.RefreshToken.rawValue)
    }
    
}
