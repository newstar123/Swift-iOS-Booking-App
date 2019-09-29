//
//  AnalyticsService.swift
//  Qorum
//
//  Created by Vadym Riznychok on 2/20/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import Mixpanel

/// Wrapper for Mixpanel analytics
class AnalyticsService {
    
    // MARK: - Shared
    static let shared = AnalyticsService()
    fileprivate init() {}
    
    /// Initial setup of the Mixpanel service.
    func setupMixpanel() {
        guard AppConfig.eventsTrackingEnabled else { return }
        let mixpanel = Mixpanel.initialize(token: SocialServiceKeys.qorumMixpanelTokenKey)
        mixpanel.registerSuperProperties(["app_name": "ios_patron"])
        if UserDefaults.standard.optionalBool(for: UserDefaultsKeys.appLaunched) == nil {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.appLaunched.rawValue)
            AnalyticsService.shared.track(event: MixpanelEvents.firstLaunchOfApp.rawValue)
        }
    }
    
    /// Wrapper for tracking registration of a new user.
    ///
    /// This method identifies user in Mixpanel and sends a tracking event to the analytics.
    ///
    /// - Parameter user: newly created user.
    func trackRegister(user: User) {
        var birthYear = ""
        if let birthdate = user.birthDate {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            dateFormatter.dateFormat = "yyyy"
            birthYear = dateFormatter.string(from: birthdate)
        }
        if AppConfig.eventsTrackingEnabled {
            let distinctId = Mixpanel.mainInstance().distinctId
            Mixpanel.mainInstance().createAlias(String(user.userId), distinctId: distinctId)
            Mixpanel.mainInstance().identify(distinctId: distinctId)
            Mixpanel.mainInstance().people.set(properties: ["First Name": user.firstName ?? "",
                                                            "Last Name": user.lastName ?? "",
                                                            "Birthdate": birthYear,
                                                            "Gender": user.gender.rawValue,
                                                            "Email": user.email ?? "",
                                                            "Phone": user.mobileNumber ?? "",
                                                            "Zip": user.zipCode ?? "",])
            let age = Calendar.current.dateComponents([.year], from: user.birthDate!, to: Date()).year
            AnalyticsService.shared.track(event: MixpanelEvents.registerForAccount.rawValue,
                                          properties: ["Gender": user.gender.rawValue,
                                                       "Age": age ?? "",
                                                       "Market": CityManager.shared.selectedCity?.name ?? ""])
        }
    }
    
    /// Wrapper for tracking login event.
    ///
    /// This method identifies user in Mixpanel and sends a tracking event to the analytics.
    ///
    /// - Parameter user: logged in user.
    func trackLogin(user: User) {
        guard AppConfig.eventsTrackingEnabled else { return }
        Mixpanel.mainInstance().identify(distinctId: Mixpanel.mainInstance().distinctId)
        Mixpanel.mainInstance().registerSuperProperties(["User Name": "\(user.firstName ?? "") \(user.lastName ?? "")", "User ID": user.userId])
    }
    
    /// Wrapper for tracking analytics events in Mixpanel.
    ///
    /// - Parameters:
    ///   - event: name of event to track.
    ///   - properties: properties dictionary.
    func track(event: String?, properties: [String: Any]? = nil) {
        guard AppConfig.eventsTrackingEnabled else { return }
        Mixpanel.mainInstance().track(event: event, properties: properties as? Properties)
    }
    
}
