//
//  Avatar.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/30/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

final class Avatar {
    
    enum ImageData {
        
        /// Locally stored image
        case localImage(UIImage)
        
        /// Remote image source URL
        case remoteURL(URL)
        
        /// Sets ImageView with image
        ///
        /// - Parameters:
        ///   - imageView: imageView to set
        ///   - completion: completion block
        func setup(into imageView: UIImageView,
                   completion: @escaping APIHandler<UIImage>) {
            switch self {
            case let .localImage(image):
                imageView.image = image
                completion(.value(image))
            case let .remoteURL(url):
                imageView.sd_setImage(with: url) { (image, error, _, _) in
                    if let image = image {
                        completion(.value(image))
                    } else if let error = error {
                        completion(.error(error))
                    } else {
                        completion(.error("Unexpected error"))
                    }
                }
            }
        }
        
    }
    
    /// Profile image ID
    let avatarId: Int
    
    /// First name
    let firstName: String?
    
    /// Last name
    let lastName: String?
    
    /// Image Data instance - represents UIImage stored locally or remote image URL
    let imageData: ImageData?
    
    /// Profile Facebook ID
    let facebookId: String?
    
    /// Returns true if friend of current user
    var isFacebookFriend: Bool
    
    /// Returns true if Facebook visability tirned to On
    let isVisible: Bool
    
    /// Profile's gender
    let gender: User.Gender?
    
    required init(avatarId: Int,
                  firstName: String?,
                  lastName: String?,
                  imageData: ImageData?,
                  facebookId: String?,
                  isFacebookFriend: Bool,
                  isVisible: Bool,
                  gender: User.Gender?)
    {
        self.avatarId = avatarId
        self.firstName = firstName
        self.lastName = lastName
        self.imageData = imageData
        self.facebookId = facebookId
        self.isFacebookFriend = isFacebookFriend
        self.isVisible = isVisible
        self.gender = gender
    }
    
    required convenience init() {
        self.init(avatarId: 0,
                  firstName: nil,
                  lastName: nil,
                  imageData: nil,
                  facebookId: nil,
                  isFacebookFriend: false,
                  isVisible: false,
                  gender: nil)
    }
    
    
    /// Generates Test Data
    ///
    /// - Returns: Test Users Array
    /// SS: Probably should be transferred to QorumConfig?
    class func generateFake() -> [Avatar] {
        var avatars: [Avatar] = []
        for i in 1...7 {
            let avatar = Avatar.init(avatarId: UUID().hashValue,
                                     firstName: nil,
                                     lastName: nil,
                                     imageData: .localImage(UIImage(named: "fakeUser\(i)")!),
                                     facebookId: nil,
                                     isFacebookFriend: false,
                                     isVisible: true,
                                     gender: nil)
            avatars.append(avatar)
        }
        return avatars
    }
    
}

// MARK: - SafeJSONAbleType
extension Avatar: SafeJSONAbleType {
    
    static var placeholder: Avatar {
        return Avatar()
    }
    
    static func from(json: JSON) throws -> Avatar {
        let patronId = try? json["patron_id"].expectingInt()
        let id = try? json["id"].expectingInt()
        guard let avatar_id = patronId ?? id else {
            throw("Avatar id is missing")
        }
        let avatarLink = try json["image_url"].expectingString()
        guard let avatarURL = URL(string: avatarLink) else {
            throw("Can't init Avatar URL with \(avatarLink) string")
        }
        let facebookId = json["facebook_id"].string
        let isFacebookFriend = User.stored.facebookFriends.contains { $0.id == facebookId }
        let facebookVisible = json["facebook_visible"].string
        let isVisible = facebookVisible == nil || facebookVisible == "on"
        return Avatar(avatarId: avatar_id,
                      firstName: json["first_name"].string,
                      lastName: json["last_name"].string,
                      imageData: .remoteURL(avatarURL),
                      facebookId: facebookId,
                      isFacebookFriend: isFacebookFriend,
                      isVisible: isVisible,
                      gender: User.Gender(rawValue: json["gender"].string ?? ""))
    }
    
}
