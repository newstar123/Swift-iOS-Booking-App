//
//  Config.swift
//  Qorum
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import CoreLocation

/// The Qorum configuration which is may be changed via Qorum Config app.
/// Stays active even after Qorum Config app removal.
class AppConfig: DefaultConfig {
    
    /// Defines `UserDefaults` suite - the domain identifier of the search list.
    /// And the `UserDefaults` it refers to is expected to be shared between this app and Qorum Config via App Group.
    private static let udSuiteName = "group.com.qorum.config"
    
    /// Defines `UserDefaults` storage for the config.
    private static let defaults = UserDefaults(suiteName: udSuiteName)!
    
    override class var environment: QorumEnvironment {
        get {
            guard
                let environmentData: Data = defaults[#function],
                let environment = try? JSONDecoder().decode(QorumEnvironment.self, from: environmentData) else
            {
                return super.environment
            }
            return environment
        } set {
            defaults[#function] = try? JSONEncoder().encode(newValue)
        }
    }
    
    override class var location: QorumLocation {
        get {
            guard
                let locationData: Data = defaults[#function],
                let location = try? JSONDecoder().decode(QorumLocation.self, from: locationData) else
            {
                return super.location
            }
            return location
        } set {
            defaults[#function] = try? JSONEncoder().encode(newValue)
        }
    }
    
    override class var developerModeEnabled: Bool {
        get { return defaults[#function] ?? super.developerModeEnabled }
        set { defaults[#function] = newValue }
    }
    
    override class var beaconsEnabled: Bool {
        get { return defaults[#function] ?? super.beaconsEnabled }
        set { defaults[#function] = newValue }
    }
    
    override class var uberSandboxModeEnabled: Bool {
        get { return defaults[#function] ?? super.uberSandboxModeEnabled }
        set { defaults[#function] = newValue }
    }
    
    class var fakeCheckinsMode: GenericConfigMode {
        get { return GenericConfigMode(boolean: defaults[#function]) }
        set { defaults[#function] = newValue.boolean }
    }
    
    override class var fakeCheckinsEnabled: Bool {
        get { return fakeCheckinsMode.boolean ?? isFakeCheckinsEnabled(for: environment) }
    }
    
    override class var eventsTrackingEnabled: Bool {
        get { return defaults[#function] ?? super.eventsTrackingEnabled }
        set { defaults[#function] = newValue }
    }
    
    class var stripeSandboxMode: GenericConfigMode {
        get { return GenericConfigMode(boolean: defaults[#function]) }
        set { defaults[#function] = newValue.boolean }
    }
    
    override class var stripeSandboxModeEnabled: Bool {
        get { return stripeSandboxMode.boolean ?? isStripeSandboxModeEnabled(for: environment) }
    }
    
    override class var billAdPlaceholder: BillAdPlaceholder {
        get {
            if  let row = defaults[#function] as IndexPath.Row?,
                let placeholder = BillAdPlaceholder(rawValue: row)
            {
                return  placeholder
            }
            return super.billAdPlaceholder
        }
        set { defaults[#function] = newValue.rawValue }
    }
    
    override class var billAdFetchEnabled: Bool {
        get { return defaults[#function] ?? super.billAdFetchEnabled }
        set { defaults[#function] = newValue }
    }
    
    override class var displayPOSInfo: Bool {
        get { return defaults[#function] ?? super.displayPOSInfo }
        set { defaults[#function] = newValue }
    }
    
    override class var quickLaunch: Bool {
        get { return defaults[#function] ?? super.quickLaunch }
        set { defaults[#function] = newValue }
    }
    
    override class var facebookReadPermissions: [FBReadPermission] {
        get {
            guard
                let permissionsData: Data = defaults[#function],
                let permissions = try? JSONDecoder().decode([FBReadPermission].self, from: permissionsData) else
            {
                return super.facebookReadPermissions
            }
            return permissions
        } set {
            let newPermissions = Array(Set(newValue)).sorted { $0.rawValue < $1.rawValue }
            defaults[#function] = try? JSONEncoder().encode(newPermissions)
        }
    }
    
    override class var allVenuesAlwaysOpen: Bool {
        get { return defaults[#function] ?? super.allVenuesAlwaysOpen }
        set { defaults[#function] = newValue }
    }
    
    override class var maxDistanceToCheckin: Double { // meters
        get { return defaults[#function] ?? super.maxDistanceToCheckin }
        set { defaults[#function] = newValue }
    }
    
    // MARK: -
    
    /// Syncronizes the associated `UserDefaults`.
    class func synchronize() {
        defaults.synchronize()
    }
    
    /// Wipes all the data stored in the associated `UserDefaults` domain.
    class func reset() {
        defaults.removePersistentDomain(forName: udSuiteName)
    }
    
}

private extension UserDefaults {
    
    subscript <T>(_ key: String) -> T? {
        get {
            return object(forKey: key) as? T
        } set {
            set(newValue as Any?, forKey: key)
        }
    }
    
}


