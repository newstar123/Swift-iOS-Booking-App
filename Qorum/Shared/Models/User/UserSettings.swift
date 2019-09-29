//
//  UserSettings.swift
//  Qorum
//
//  Created by Dima Tsurkan on 10/3/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// Launch Counter max value
    private static let maxEffectiveCount = 3
    
    /// UserDefaults Key for Launch Counter
    private static let launchCountKey = "LaunchesCountKey"
    
    /// UserDefaults Key for Accessory Slider flag
    private static let isListTabAccessoryEverSlidedKey = "isListTabAccessoryEverSlided"
    
    /// Launch Counter
    private(set) var launchCount: Int {
        get {
            return integer(forKey: UserDefaults.launchCountKey)
        } set {
            set(newValue, forKey: UserDefaults.launchCountKey)
        }
    }
    
    /// Accessory Slider flag
    var isListTabAccessoryEverSlided: Bool {
        get { return bool(forKey: UserDefaults.isListTabAccessoryEverSlidedKey) }
        set { set(newValue, forKey: UserDefaults.isListTabAccessoryEverSlidedKey)}
    }
    
    /// Increases Launch Counter
    func increaseLaunchCount() {
        let defaults = UserDefaults.standard
        guard defaults.launchCount < UserDefaults.maxEffectiveCount else { return }
        defaults.launchCount += 1
    }
    
    /// Resets Launch Counter
    func resetLaunchCount() {
        UserDefaults.standard.launchCount = 0
    }
    
    /// UserDefaults Key for User settings
    private static let userSettingsKey = "UserSettings"
    
    /// UserSettings stored/restored from UserDefaults
    fileprivate(set) var userSettingData: Data? {
        get {
            return data(forKey: UserDefaults.userSettingsKey)
        } set {
            guard let data = newValue else {
                removeObject(forKey: UserDefaults.userSettingsKey)
                return
            }
            set(data, forKey: UserDefaults.userSettingsKey)
        }
    }
    
}

struct ScreenOverlaySet: OptionSet, Codable {
    let rawValue: Int
    static let introScreens = ScreenOverlaySet(rawValue: 1)
    static let mainOverlay = ScreenOverlaySet(rawValue: 2)
    static let venueOverlay = ScreenOverlaySet(rawValue: 4)
    static let venueFacebookOverlay = ScreenOverlaySet(rawValue: 8)
    static let billOverlay = ScreenOverlaySet(rawValue: 16)
}

class UserSettings: Codable {
    
    /// Overlay Layers Order
    var screenOverlaysSeen: ScreenOverlaySet = []
    
    /// Uber token
    var uber_token: String?
    
    /// Uber Refresh token
    var refresh_token: String?
    
    /// Uber Request ID
    var uberRequestId: String?
    
    /// Whether to display arrows for the open tab slider.
    var isListTabAccessoryEverSlided: Bool {
        get { return UserDefaults.standard.isListTabAccessoryEverSlided }
        set { UserDefaults.standard.isListTabAccessoryEverSlided = newValue }
    }
    
    /// Launch Counter
    var launchCount: Int {
        return UserDefaults.standard.launchCount
    }
}
