//
//  Metadata.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/29/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON

final class Metadata: NSObject, Codable {
    fileprivate let id: String
    
    /// Available Venue Features
    fileprivate (set) var features: [MetadataTemplate]
    
    /// Available Venue Insider Tips
    fileprivate (set) var insiderTips: [MetadataTemplate]
    
    required override init() {
        id = "MetadataSingle"
        features = []
        insiderTips = []
    }
    
    /// Returns Metadata stored in UserDefaults
    static var stored: Metadata? {
        let defaults = UserDefaults.standard
        guard let metaData = defaults.metaData else { return .none }
        do {
            return try Metadata.decoded(from: metaData)
        } catch {
            print("Meta decoding error:", error)
            defaults.metaData = nil
            return .none
        }
    }
    
    /// Stores Metadata to UserDefaults
    func save() {
        do {
            UserDefaults.standard.metaData = try encode()
            UserDefaults.standard.synchronize()
        } catch {
            print("Meta encoding error:", error)
        }
    }
    
    /// Rmoves metadata from UserDefaults
    func delete() {
        UserDefaults.standard.metaData = nil
        UserDefaults.standard.synchronize()
    }
}

final class MetadataTemplate: NSObject, Codable {
    
    /// Metadata Item ID
    let identifier: String
    
    /// returns true if metadata's label has special marker "__"
    ///
    fileprivate (set) var requiresData: Bool
    
    /// Metadata Item icon
    fileprivate (set) var icon_url: String?
    
    /// Metadata Item Title
    fileprivate (set) var label: String?
    
    required override init() {
        self.identifier = ""
        self.requiresData = false
        self.icon_url = .none
        self.label = .none
    }
    
    required init(identifier: String,
         requiresData: Bool = false,
         icon_url: String? = "",
         label: String? = "") {
        self.identifier = identifier
        self.requiresData = requiresData
        self.icon_url = icon_url
        self.label = label
    }
}


// MARK: - JSONAbleType
extension Metadata: JSONAbleType {
    
    static func from(json: JSON) throws -> Metadata {
        let metadata = Metadata()
        
        for (_,feature_json):(String, JSON) in json["features"] {
            if let identifier = feature_json["id"].string {
                let feature = MetadataTemplate(identifier:identifier)
                
                if let iconUrl = feature_json["iconUrl"].string {
                    var url = "\(AppConfig.environment.url.absoluteString)\(iconUrl)"
                    if iconUrl.hasPrefix("http") {
                        url = iconUrl
                    }
                    if url.count > 0 {
                        feature.icon_url = url
                    }
                }
                
                if let label = feature_json["label"].string {
                    if label.range(of: "__") != nil {
                        feature.requiresData = true
                        feature.label = label.replacingOccurrences(of: "__", with: "%@")
                    } else {
                        feature.requiresData = false
                        feature.label = label
                    }
                }
                metadata.features.append(feature)
            }
        }
        
        for (_,insider_json):(String, JSON) in json["insiderTips"] {
            if let identifier = insider_json["id"].string {
                let insiderTip = MetadataTemplate(identifier:identifier)
                
                if let iconUrl = insider_json["iconUrl"].string {
                    var url = "\(AppConfig.environment.url.absoluteString)\(iconUrl)"
                    if iconUrl.hasPrefix("http") {
                        url = iconUrl
                    }
                    if url.count > 0 {
                        insiderTip.icon_url = url
                    }
                }
                
                if let label = insider_json["label"].string {
                    if label.range(of: "__") != nil {
                        insiderTip.requiresData = true
                        insiderTip.label = label.replacingOccurrences(of: "__", with: "%@")
                    } else {
                        insiderTip.requiresData = false
                        insiderTip.label = label
                    }
                }
                metadata.insiderTips.append(insiderTip)
            }
        }
        
        return metadata
    }
    
}

extension UserDefaults {
    
    private static let metaKey = "StoredMetadata"
    
    fileprivate(set) var metaData: Data? {
        get {
            return data(forKey: UserDefaults.metaKey)
        } set {
            guard let data = newValue else {
                removeObject(forKey: UserDefaults.metaKey)
                return
            }
            set(data, forKey: UserDefaults.metaKey)
        }
    }
    
}
