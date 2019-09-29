//
//  User.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/3/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON
import PhoneNumberKit

extension UserDefaults {
    
    /// UserDefaults key to store user
    private static let userKey = "StoredUser"
    
    /// User data stored/restored from UserDefaults
    fileprivate(set) var userData: Data? {
        get {
            return data(forKey: UserDefaults.userKey)
        } set {
            guard let data = newValue else {
                removeObject(forKey: UserDefaults.userKey)
                return
            }
            set(data, forKey: UserDefaults.userKey)
        }
    }
    
}

final class User: Codable {
    
    enum Gender: String, Codable {
        case male = "M"
        case female = "F"
        case unspecified = ""
        
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "male", "m": self = .male
            case "female", "f": self = .female
            default: self = .unspecified
            }
        }
        
        /// Api keys for gender
        var stringValue: String? {
            switch self {
            case .male,
                 .female: return rawValue
            case .unspecified: return nil
            }
        }
        
        /// Title for gender
        var readable: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .unspecified: return ""
            }
        }
        
        /// Localized title
        var readableLocalized: String {
            return NSLocalizedString(readable, comment: "")
        }
        
        /// Presenting color
        var color: UIColor {
            switch self {
            case .male: return UIColor(in8bit: 0, 164, 211)
            case .female: return UIColor(in8bit: 128, 15, 173)
            case .unspecified: return .clear
            }
        }
        
    }
    
    /// Current User stored in User Defaults
    static var stored: User {
        let defaults = UserDefaults.standard
        guard let userData = defaults.userData else { return guestUser }
        do {
            return try User.decoded(from: userData)
        } catch {
            print("User decoding error:", error)
            defaults.userData = nil
            return guestUser
        }
    }
    
    /// User ID
    var userId = -1
    
    /// First name
    var firstName: String?
    
    /// Last name
    var lastName: String?
    
    /// Birthday
    var birthDate: Date?
    
    /// User's gender
    var gender: Gender = .unspecified
    
    /// Billing zipcode
    var zipCode: String?
    
    /// User's Phone number
    var mobileNumber: String? {
        didSet {
            phoneFormatted = formatPhone()
        }
    }
    
    /// User's email
    var email: String?
    
    /// Returns true if user verified email
    var isEmailVerified = false
    
    /// Returns true if user verified phone number
    var isPhoneVerified = false
    
    /// Profile image URL
    var avatarURL: URL?
    
    /// Returns true if current profile image was not confirmed by user
    var isAvatarPlaceholder = false
    
    /// Number of users who accepted invite
    var invitesAccepted = 0
    
    /// Number of friends who checked in
    var friendsWhoHaveCheckedIn = 0
    
    /// Drink credits amount remaining
    var remainingDrinkCredits = 0
    
    /// Amount saved
    var totalSaved = 0
    
    /// Default payment method id
    var defaultPayment: String?
    
    /// Whether to notify Facebook friends user in the venue.
    var facebookVisible: String?
    
    /// Date when Facebook visibility was turned on
    var facebookOnFrom: Date?
    
    /// Code to reffer a friend
    var referralCode: String?
    
    /// Used for getting the share link
    var branchLink: String?
    
    /// Returns true if user registered via Facebook
    var facebookSupplied: [String] = []
    
    /// Current user settings
    var settings = UserSettings()
    
    /// Friends from Facebook
    var facebookFriends: [FBFriend] = []
    
    /// Returns true if Facebook's visibility was not restricted
    var isFacebookVisible: Bool {
        return facebookVisible == nil || facebookVisible == "on"
    }
    
    /// Age in years
    var age: Int? {
        guard let birthDate = birthDate else { return nil }
        let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
    
    /// Returns true if user's age more than 21
    var isMature: Bool {
        guard let age = age else { return true }
        return age >= 21
    }
    
    /// Returns true if user verified email and phone number
    var isAllVerified: Bool {
        return isEmailVerified && isPhoneVerified || isGuest
    }
    
    /// Human-readable phone number
    private(set) lazy var phoneFormatted = formatPhone()
    
    /// Formats phone number with international format
    ///
    /// - Returns: formatted string
    private func formatPhone() -> String? {
        let phoneNumberKit = PhoneNumberKit()
        if let number = try? phoneNumberKit.parse(mobileNumber ?? "") {
            return phoneNumberKit.format(number, toType: .international)
        } else {
            return mobileNumber
        }
    }
    
    init() {
        
    }
    
    init(id: Int,
         firstName: String?,
         lastName: String?,
         birthDate: Date?,
         gender: Gender,
         zipCode: String?,
         mobileNumber: String?,
         email: String?,
         isEmailVerified: Bool,
         isPhoneVerified: Bool,
         avatarURL: URL?,
         invitesAccepted: Int,
         friendsWhoHaveCheckedIn: Int,
         remainingDrinkCredits: Int,
         totalSaved: Int,
         defaultPayment: String?,
         facebookVisible: String?,
         facebookOnFrom: Date?,
         referralCode: String?,
         branchLink: String?,
         facebookSupplied: [String],
         settings: UserSettings,
         facebookFriends: [FBFriend])
    {
        self.userId = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.zipCode = zipCode
        self.mobileNumber = mobileNumber
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.isPhoneVerified = isPhoneVerified
        self.avatarURL = avatarURL
        self.invitesAccepted = invitesAccepted
        self.friendsWhoHaveCheckedIn = friendsWhoHaveCheckedIn
        self.remainingDrinkCredits = remainingDrinkCredits
        self.totalSaved = totalSaved
        self.defaultPayment = defaultPayment
        self.facebookVisible = facebookVisible
        self.facebookOnFrom = facebookOnFrom
        self.referralCode = referralCode
        self.branchLink = branchLink
        self.facebookSupplied = facebookSupplied
        self.settings = settings
        self.facebookFriends = facebookFriends
    }
    
    /// Stores user data to UserDefaults
    func save() {
        guard !isGuest else { return } // saving a guest user doesn't make a sense
        do {
            UserDefaults.standard.userData = try encode()
            if isEmailVerified {
                UserDefaults.standard.set(false, for: .pendingEmailVerification)
            }
            UserDefaults.standard.synchronize()
        } catch {
            print("User encoding error:", error)
        }
    }
    
    /// Removes user data from UserDefaults
    func delete() {
        UserDefaults.standard.userData = nil
        UserDefaults.standard.synchronize()
    }
    
    
    /// Checks whether user's email is verified
    ///
    /// - Parameter completion: completion block
    func checkEmailStatus(completion: @escaping (Bool)->()) {
        let profileWorker = ProfileWorker()
        profileWorker.fetchAndSave(user: self) { user in
            completion(user?.isEmailVerified ?? false)
        }
    }
    
}

extension User {
    
    /// Temporary User without sign in/sign up
    static var guestUser: User {
        return User()
    }
    
    /// Returns true if current user is Guest
    var isGuest: Bool {
        return -1 == userId
    }
    
}

// MARK: - JSONAbleType
extension User: JSONAbleType {
    
    static func from(json: JSON) throws -> User {
        let userId = try json["id"].expectingInt()
        let firstName = json["first_name"].string
        let lastName = json["last_name"].string
        let email = json["email"].string
        let zipCode = json["zip"].string
        let mobileNumber: String? = {
            guard let phone = json["phone"].string else { return nil }
            if let countryCode = json["country_code"].string {
                return "\(countryCode)\(phone)"
            }
            return phone
        }()
        let isEmailVerified = json["email_verified"].boolValue
        let isPhoneVerified = json["phone_verified"].boolValue
        let totalSaved = json["total_saved"].int ?? 0
        let facebookVisible = json["facebook_visible"].string
        let defaultPayment = json["default_payment_method"].string
        let invitesAccepted = json["invites_accepted"].int ?? 0
        let friendsWhoHaveCheckedIn = json["friends_who_have_checked_in"].int ?? 0
        let remainingDrinkCredits = json["free_drinks"].int ?? 0
        
        var facebookOnFrom: Date?
        if let from = json["facebook_on_from"].string {
            facebookOnFrom = Date.standardDateFormatter.date(from: from)
        }
        
        var avatarURL: URL?
        if let imageURL = json["image_url"].string {
            avatarURL = URL(string: imageURL)
        }
        
        let gender = Gender(rawValue: json["gender"].string ?? "")
        
        var birthDate: Date?
        if let dob = json["birthdate"].string {
            birthDate = Date.standardDateFormatter.date(from: dob)
        } else if let dob = json["birthday"].string {
            birthDate = Date.apiBirthdayFormatter.date(from: dob)
        }
        
        // TODO: fix response on backend and remove hack @vriznychok
        var referralCodeJSON: JSON
        if let referralJSON = json["referralCodes"].array?.first {
            referralCodeJSON = referralJSON
        } else {
            referralCodeJSON = json["referralCodes"]
        }
        
        let referralCode = referralCodeJSON["code"].string
        let branchLink = referralCodeJSON["branch_link"].string
        let facebookSupplied = json["facebook_supplied"].arrayValue
            .compactMap { $0.string }
        let userSettings = UserSettings()
        
        return User(id: userId,
                    firstName: firstName,
                    lastName: lastName,
                    birthDate: birthDate,
                    gender: gender,
                    zipCode: zipCode,
                    mobileNumber: mobileNumber,
                    email: email,
                    isEmailVerified: isEmailVerified,
                    isPhoneVerified: isPhoneVerified,
                    avatarURL: avatarURL,
                    invitesAccepted: invitesAccepted,
                    friendsWhoHaveCheckedIn: friendsWhoHaveCheckedIn,
                    remainingDrinkCredits: remainingDrinkCredits,
                    totalSaved: totalSaved,
                    defaultPayment: defaultPayment,
                    facebookVisible: facebookVisible,
                    facebookOnFrom: facebookOnFrom,
                    referralCode: referralCode,
                    branchLink: branchLink,
                    facebookSupplied: facebookSupplied,
                    settings: userSettings,
                    facebookFriends: [])
    }
    
}
