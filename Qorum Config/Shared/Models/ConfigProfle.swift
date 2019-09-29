//
//  ConfigProfle.swift
//  Qorum Config
//
//  Created by Stanislav on 15.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

/// The structure for storing and reusing different sets of App config, which called Profile.
struct ConfigProfile: UserDefaultsStorable {
    
    var title: StorableTitle
    
    /// Defines Qorum environment.
    var environment: QorumEnvironment
    
    /// Defines location settings.
    var location: QorumLocation
    
    /// Whether to display Developer mode alerts.
    var developerModeEnabled: Bool
    
    /// Whether to start monitoring/ranging the beacons when necessary.
    var beaconsEnabled: Bool
    
    /// Whether to replace real checkins with the fakes.
    /// `nil` means automatic, where behavior is defined by `environment`
    var fakeCheckinsEnabled: Bool?
    
    /// Whether to use Uber Sandbox or Production services.
    /// Used for testing Uber features.
    var uberSandboxModeEnabled: Bool
    
    /// Whether to enable Analytics tracking, like Mixpanel.
    var eventsTrackingEnabled: Bool
    
    /// Whether to use Stripe Sandbox or Production services.
    /// `nil` means automatic, where behavior is defined by `environment`
    var stripeSandboxModeEnabled: Bool?
    
    /// Defines the `UIImage` to use as advertisement placeholder in the Bill screen.
    var billAdPlaceholder: BillAdPlaceholder
    
    /// Whether to fetch the advertisement image from Qorum for the Bill screen.
    /// If disabled, will only display the placeholder.
    var billAdFetchEnabled: Bool
    
    /// Whether to display POS type label for the Venue cell/details screen.
    var displayPOSInfo: Bool
    
    /// Whether to bypass stratup timing constraints and get UI accessible ASAP.
    /// Used to save time while testing the app.
    var quickLaunch: Bool
    
    /// The set of enabled Facebook read permissins. Used on Facebook login.
    /// You have to check these setting if you want to update required permissing
    /// in order to get logged in without waiting for new build.
    var facebookReadPermissions: [FBReadPermission]
    
    /// Whether to bypass the venue status behavior and make it always be open no matter what.
    /// Used for testing purposes.
    var allVenuesAlwaysOpen: Bool
    
    /// Defines the range in meters where you are able to open a tab in the Venue that is within it.
    /// Used for testing purposes.
    /// Recommended value is 250 meters.
    var maxDistanceToCheckin: Double
    
    /// Returns `ConfigProfile` which is identic to the `DefaultConfig`.
    static var defaultProfile: ConfigProfile {
        return ConfigProfile(title: .default,
                             environment: DefaultConfig.environment,
                             location: DefaultConfig.location,
                             developerModeEnabled: DefaultConfig.developerModeEnabled,
                             beaconsEnabled: DefaultConfig.beaconsEnabled,
                             fakeCheckinsEnabled: nil,
                             uberSandboxModeEnabled: DefaultConfig.uberSandboxModeEnabled,
                             eventsTrackingEnabled: DefaultConfig.eventsTrackingEnabled,
                             stripeSandboxModeEnabled: nil,
                             billAdPlaceholder: DefaultConfig.billAdPlaceholder,
                             billAdFetchEnabled: DefaultConfig.billAdFetchEnabled,
                             displayPOSInfo: DefaultConfig.displayPOSInfo,
                             quickLaunch: DefaultConfig.quickLaunch,
                             facebookReadPermissions: DefaultConfig.facebookReadPermissions,
                             allVenuesAlwaysOpen: DefaultConfig.allVenuesAlwaysOpen,
                             maxDistanceToCheckin: DefaultConfig.maxDistanceToCheckin)
    }
    
    static let userDefaultsSuiteName = "ConfigProfiles"
    
    static var placeholders: [ConfigProfile] {
        var stagingProfile = ConfigProfile.defaultProfile
        stagingProfile.title = " Staging Chernivtsi"
        stagingProfile.environment = .staging
        stagingProfile.location = .custom(.init(latitude: 48.2726, longitude: 25.9441))
        var demoProfile = ConfigProfile.defaultProfile
        demoProfile.title = " Demo Los Angeles"
        demoProfile.environment = .demo
        demoProfile.location = .custom(.init(latitude: 34.0463, longitude: -118.234))
        demoProfile.developerModeEnabled = false
        demoProfile.beaconsEnabled = false
        demoProfile.uberSandboxModeEnabled = false
        demoProfile.billAdPlaceholder = .budweiser
        demoProfile.billAdFetchEnabled = false
        var prodProfile = ConfigProfile.defaultProfile
        prodProfile.title = " Production Minsk"
        prodProfile.environment = .production
        prodProfile.location = .custom(.init(latitude: 53.8862, longitude: 27.5567))
        return [stagingProfile, demoProfile, prodProfile]
    }
    
    /// Returns `ConfigProfile` which is identic to the `AppConfig`.
    /// So it's defined as current/selected profile.
    static var currentUntitled: ConfigProfile? {
        return ConfigProfile(title: .untitled,
                             environment: AppConfig.environment,
                             location: AppConfig.location,
                             developerModeEnabled: AppConfig.developerModeEnabled,
                             beaconsEnabled: AppConfig.beaconsEnabled,
                             fakeCheckinsEnabled: AppConfig.fakeCheckinsMode.boolean,
                             uberSandboxModeEnabled: AppConfig.uberSandboxModeEnabled,
                             eventsTrackingEnabled: AppConfig.eventsTrackingEnabled,
                             stripeSandboxModeEnabled: AppConfig.stripeSandboxMode.boolean,
                             billAdPlaceholder: AppConfig.billAdPlaceholder,
                             billAdFetchEnabled: AppConfig.billAdFetchEnabled,
                             displayPOSInfo: AppConfig.displayPOSInfo,
                             quickLaunch: AppConfig.quickLaunch,
                             facebookReadPermissions: AppConfig.facebookReadPermissions,
                             allVenuesAlwaysOpen: AppConfig.allVenuesAlwaysOpen,
                             maxDistanceToCheckin: AppConfig.maxDistanceToCheckin)
    }
    
    func apply() {
        AppConfig.reset()
        AppConfig.environment = environment
        AppConfig.location = location
        AppConfig.developerModeEnabled = developerModeEnabled
        AppConfig.beaconsEnabled = beaconsEnabled
        AppConfig.fakeCheckinsMode = GenericConfigMode(boolean: fakeCheckinsEnabled)
        AppConfig.uberSandboxModeEnabled = uberSandboxModeEnabled
        AppConfig.eventsTrackingEnabled = eventsTrackingEnabled
        AppConfig.stripeSandboxMode = GenericConfigMode(boolean: stripeSandboxModeEnabled)
        AppConfig.billAdPlaceholder = billAdPlaceholder
        AppConfig.billAdFetchEnabled = billAdFetchEnabled
        AppConfig.displayPOSInfo = displayPOSInfo
        AppConfig.quickLaunch = quickLaunch
        AppConfig.facebookReadPermissions = facebookReadPermissions
        AppConfig.allVenuesAlwaysOpen = allVenuesAlwaysOpen
        AppConfig.maxDistanceToCheckin = maxDistanceToCheckin
    }
    
    // MARK: - Overriding UserDefaultsStorable
    
    /// Whether the `ConfigProfile` is found in the associated `UserDefaults`
    var isAlreadyStored: Bool {
        if self == ConfigProfile.defaultProfile { return true }
        return ConfigProfile.stored.contains(self)
    }
    
    /// Returns current `ConfigProfile` stored with title it stored with.
    /// Or returns `defaultProfile` if `currentUntitled` equals it (including its title).
    /// Or, returns `nil`, if failed to find one in the storage.
    static var currentStored: ConfigProfile? {
        guard let untitled = currentUntitled else { return nil }
        let stored = self.stored
        if let selectedIndex = stored.index(of: untitled) {
            return stored[selectedIndex]
        }
        if untitled == .defaultProfile {
            return .defaultProfile
        }
        return nil
    }
    
}

// MARK: - Codable
extension ConfigProfile {
    
    /// Decodes `ConfigProfile` from JSON `Data`
    /// If any property fails to get decoded, it will be defaulted to the `DefaultConfig`'s one.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        /// Decodes a property of the `ConfigProfile` for given key
        ///
        /// - Parameter key: The key that the decoded property is associated with
        /// - Returns: Decoded value or `nil` in case of failure
        func decode<T: Decodable>(_ key: CodingKeys) -> T? {
            guard let container = container else { return nil }
            return try? container.decode(T.self, forKey: key)
        }
        
        title = decode(.title) ?? StorableTitle.untitled
        environment = decode(.environment) ?? DefaultConfig.environment
        location = decode(.location) ?? DefaultConfig.location
        developerModeEnabled = decode(.developerModeEnabled) ?? DefaultConfig.developerModeEnabled
        beaconsEnabled = decode(.beaconsEnabled) ?? DefaultConfig.beaconsEnabled
        fakeCheckinsEnabled = decode(.fakeCheckinsEnabled)
        uberSandboxModeEnabled = decode(.uberSandboxModeEnabled) ?? DefaultConfig.uberSandboxModeEnabled
        eventsTrackingEnabled = decode(.eventsTrackingEnabled) ?? DefaultConfig.eventsTrackingEnabled
        stripeSandboxModeEnabled = decode(.stripeSandboxModeEnabled)
        billAdPlaceholder = decode(.billAdPlaceholder) ?? DefaultConfig.billAdPlaceholder
        billAdFetchEnabled = decode(.billAdFetchEnabled) ?? DefaultConfig.billAdFetchEnabled
        displayPOSInfo = decode(.displayPOSInfo) ?? DefaultConfig.displayPOSInfo
        quickLaunch = decode(.quickLaunch) ?? DefaultConfig.quickLaunch
        facebookReadPermissions = decode(.facebookReadPermissions) ?? DefaultConfig.facebookReadPermissions
        allVenuesAlwaysOpen = decode(.allVenuesAlwaysOpen) ?? DefaultConfig.allVenuesAlwaysOpen
        maxDistanceToCheckin = decode(.maxDistanceToCheckin) ?? DefaultConfig.maxDistanceToCheckin
    }
    
}
