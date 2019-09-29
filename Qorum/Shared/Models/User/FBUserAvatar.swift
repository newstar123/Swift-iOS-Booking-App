//
//  FBUserAvatar.swift
//  Qorum
//
//  Created by Stanislav on 24.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import SwiftyJSON

struct FBUserAvatar {
    
    /// Facebook profile image URL
    var url: URL?
    
    /// Returns true if user confirmed using image as avatar
    var isPlaceholder: Bool
}

// MARK: - JSONAbleType
extension FBUserAvatar: JSONAbleType {
    
    static func from(json: JSON) throws -> FBUserAvatar {
        let data = json["data"]
        let urlString = try data["url"].expectingString()
        let url = URL(string: urlString)
        let isPlaceholder = data["is_silhouette"].boolValue
        return FBUserAvatar(url: url, isPlaceholder: isPlaceholder)
    }
    
}
