//
//  DefaultConfig.swift
//  Qorum
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

/// The Qorum configuration which is used by default i.e without Qorum Config installed.
class DefaultConfig {
    
    /// Defines Qorum environment.
    class var environment: QorumEnvironment { return .production }
    
    /// Defines location settings.
    class var location: QorumLocation { return .real }
    
    /// Whether to display Developer mode alerts.
    class var developerModeEnabled: Bool { return false }
    
    /// Whether to start monitoring/ranging the beacons when necessary.
    class var beaconsEnabled: Bool { return true }
    
    /// Whether to replace real checkins with the fakes.
    class var fakeCheckinsEnabled: Bool { return isFakeCheckinsEnabled(for: environment) }
    
    /// Whether to use Uber Sandbox or Production services.
    /// Used for testing Uber features.
    class var uberSandboxModeEnabled: Bool { return false }
    
    /// Whether to enable Analytics tracking, like Mixpanel.
    class var eventsTrackingEnabled: Bool { return true }
    
    /// Whether to use Stripe Sandbox or Production services.
    class var stripeSandboxModeEnabled: Bool { return isStripeSandboxModeEnabled(for: environment) }
    
    /// Defines the `UIImage` to use as advertisement placeholder in the Bill screen.
    class var billAdPlaceholder: BillAdPlaceholder { return .absolutElyx }
    
    /// Whether to fetch the advertisement image from Qorum  server for the Bill screen.
    /// If disabled, will only display the placeholder.
    class var billAdFetchEnabled: Bool { return true }
    
    /// Whether to display POS type label for the Venue cell/details screen.
    class var displayPOSInfo: Bool { return false }
    
    /// Whether to bypass stratup timing constraints and get UI accessible ASAP.
    /// Used to save time while testing the app.
    class var quickLaunch: Bool { return false }
    
    /// The set of enabled Facebook read permissins. Used on Facebook login.
    /// You have to check these setting if you want to update required permissing
    /// in order to get logged in without waiting for new build.
    class var facebookReadPermissions: [FBReadPermission] {
        let permissions: [FBReadPermission]
        permissions = [.email, .publicProfile, .userBirthday, .userFriends, .userGender]
        return permissions.sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Whether to bypass the venue status behavior and make it always be open no matter what.
    /// Used for testing purposes.
    class var allVenuesAlwaysOpen: Bool { return false }
    
    
    /// Defines the range in meters where you are able to open a tab in the Venue that is within it.
    /// Used for testing purposes.
    /// Recommended (default) value is 250 meters.
    class var maxDistanceToCheckin: Double { return 250 }
    
    /// - Parameter environment: Defines preferred `fakeCheckinsEnabled` setting.
    /// - Returns: Preferred `fakeCheckinsEnabled` setting for given `environment`.
    class func isFakeCheckinsEnabled(for environment: QorumEnvironment) -> Bool {
        switch environment.path {
        case .staging, .production, .custom: return false
        case .demoStaging, .demo: return true
        }
    }
    
    /// - Parameter environment: Defines preferred `stripeSandboxModeEnabled` setting.
    /// - Returns: Preferred `stripeSandboxModeEnabled` setting for given `environment`.
    class func isStripeSandboxModeEnabled(for environment: QorumEnvironment) -> Bool {
        switch environment.path {
        case .staging,
             .demoStaging,
             .demo,
             .custom: return true
        case .production: return false
        }
    }
    
    /// The class is designed to be instanceless.
    private init() { }
    
}

