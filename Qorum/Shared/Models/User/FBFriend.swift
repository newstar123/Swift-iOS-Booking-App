//
//  FBFriend.swift
//  Qorum
//
//  Created by Stanislav on 23.01.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON

final class FBFriend: Codable {
    
    /// Facebook friend ID
    var id: String?
    
    /// Facebook friend name
    var name: String?
    
    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
    
    /// Fetches friends from Facebook
    ///
    /// - Parameter completion: completion block
    static func fetch(completion: @escaping APIHandler<[FBFriend]>) {
        let request = FacebookRequest(target: .friends)
        request.performArrayDecoding(for: "data", completion: completion)
    }
    
}

// MARK: - JSONAbleType
extension FBFriend: JSONAbleType {
    
    static func from(json: JSON) throws -> FBFriend {
        let id = json["id"].string
        let name = json["name"].string
        return FBFriend(id: id, name: name)
    }
    
}

