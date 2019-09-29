//
//  FBUser.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/27/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FBUser {
    
    /// First name
    var firstName: String
    
    /// Last name
    var lastName: String
    
    /// User's email
    var email: String
    
    /// User's birthday
    var birthDate: Date?
    
    /// Gender
    var gender: User.Gender
    
    /// Avatar from Facebook
    var avatar: FBUserAvatar
    
    /// Fetches Facebook user
    ///
    /// - Parameter completion: completion handler
    static func fetch(completion: @escaping APIHandler<FBUser>) {
        let request = FacebookRequest(target: .profile)
        request.performDecoding(completion: completion)
    }
    
}

// MARK: - JSONAbleType
extension FBUser: JSONAbleType {
    
    static func from(json: JSON) throws -> FBUser {
        let email = json["email"].stringValue
        let firstName = json["first_name"].stringValue
        let lastName = json["last_name"].stringValue
        let birthdayString = json["birthday"].stringValue
        let birthDate = Date.apiBirthdayFormatter.date(from: birthdayString)
        let genderString = json["gender"].stringValue
        let gender = User.Gender(rawValue: genderString)
        let avatar = try FBUserAvatar.from(json: json["picture"])
        return FBUser(firstName: firstName,
                      lastName: lastName,
                      email: email,
                      birthDate: birthDate,
                      gender: gender,
                      avatar: avatar)
    }
    
}
