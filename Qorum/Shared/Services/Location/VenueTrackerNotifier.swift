//
//  VenueTrackerNotifier.swift
//  Qorum
//
//  Created by Vadym Riznychok on 2/23/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UserNotifications

/// Helper for managing notifications/alert that relates on checkin/checkout process.
class VenueTrackerNotifier {
    
    /// Wrapper for convenient adding local notifications.
    ///
    /// - Parameters:
    ///   - identifier: An identifier for the request.
    ///   - content: The content of the notification.
    ///   - trigger: The condition that causes the notification to be delivered.
    class func showNotification(with identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger? = nil) {
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                debugPrint("Did show notification: \(identifier)")
        })
    }
    
    /// Creates a local notification to determine which bar is near the user with a suggestion to open a new tab there.
    ///
    /// - Parameter venue: detected venue.
    class func showRegionNotif(for venue: Venue) {
        let title = "You’ve been in range of \(venue.name)."
        let message = "Would you like to check in?"
        let checkinActionTitle = "Check In"
        
        switch UIApplication.shared.applicationState {
            
        case .active:
            
            guard UserDefaults.standard.bool(for: .autoOpenTabKey) == false else { fallthrough }
            
            let checkinAction: UIAlertController.CustomAction = (checkinActionTitle,
                                                                 .default,
                                                                 { requestAutoOpenTab(venue, shouldCheckin: true) }
            )
            let dismissAction: UIAlertController.CustomAction = ("Dismiss",
                                                                 .cancel,
                                                                 { requestAutoOpenTab(venue, shouldCheckin: false) }
            )
            UIAlertController.presentAsAlert(title: title,
                                             message: message,
                                             actions: [checkinAction, dismissAction]
            )
        default:
            
            let checkinAction = UNNotificationAction(identifier: QorumPushIdentifier.beaconsCheckinRequestAction.rawValue,
                                                     title: checkinActionTitle,
                                                     options: [.foreground])
            
            let checkinCategory = UNNotificationCategory(
                identifier: "checkin.category",
                actions: [checkinAction],
                intentIdentifiers: [],
                options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([checkinCategory])
            
            let identifier = QorumPushIdentifier.beaconsRangedRegion.rawValue
            let body = title + " " + message
            let content = UNMutableNotificationContent.create(with:  venue.name,
                                                              body: body,
                                                              categoryIdentifier: "checkin.category")
            VenueTrackerNotifier.showNotification(with: identifier, content: content)
        }
    }
    
    /// Creates a local notification that notifies that user has successfuly opened a new tab in a given venue.
    ///
    /// - Parameter venue: venue with a new checkin.
    class func showCheckedInNotifications(for venue: Venue) {
        let identifier = QorumPushIdentifier.beaconsCheckedIn.rawValue
        let content = UNMutableNotificationContent.create(with: venue.name,
                                                          body: "You’ve been automatically checked into \(venue.name)",
            venue: venue)
        VenueTrackerNotifier.showNotification(with: identifier, content: content)
    }
    
    /// Creates a local notification that notifies that user hasn't verified his phone number.
    class func showPhoneVerifyNotif() {
        let identifier = QorumPushIdentifier.verifyPhone.rawValue
        let body = "Please verify your phone before closing the Tab to keep your account and Qorum safe"
        let content = UNMutableNotificationContent.create(body: body)
        VenueTrackerNotifier.showNotification(with: identifier, content: content)
    }
    
    /// Creates a local notification that notifies user about exiting venue's region.
    ///
    /// - Parameter venue: venue that user has left.
    class func notifyOnExitRegion(for venue: Venue) {
        
        let title = "Headsup: You've exited \(venue.name)."
        let message = "If you do not re-enter the Venue with \(kDelayedCheckoutMinutes) minutes, your tab will be automatically closed."
        let okActionTitle = "Ok"
        
        switch UIApplication.shared.applicationState {
            
        case .active:
            
            UIAlertController.presentAsAlert(title: title,
                                             message: message,
                                             actions: [(okActionTitle, .default, nil)]
            )
        default:
            
            let okAction = UNNotificationAction(identifier: QorumPushIdentifier.beaconsCheckingOutRequestAction.rawValue,
                                                     title: okActionTitle,
                                                     options: [])
            
            let category = UNNotificationCategory(
                identifier: QorumPushIdentifier.beaconsCheckingOutRequest.rawValue,
                actions: [okAction],
                intentIdentifiers: [],
                options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            let body = title + " " + message
            let content = UNMutableNotificationContent.create(with: venue.name,
                                                              body: body,
                                                              categoryIdentifier: category.identifier)
            VenueTrackerNotifier.showNotification(with: category.identifier, content: content)
        }
    }
    
    /// Creates a local notification that notifies user about re-entering the venue and declining of the checkout request.
    ///
    /// - Parameter venue: venue that user has returned to.
    class func notifyOnCheckoutCanceling(for venue: Venue) {
        
        let title = "You've re-entered \(venue.name), so your tab is still open."
        let message = ""
        let okActionTitle = "Ok"
        
        switch UIApplication.shared.applicationState {
            
        case .active:
                        
            UIAlertController.presentAsAlert(title: title,
                                             message: message,
                                             actions: [(okActionTitle, .default, nil)]
            )
        default:
            
            let okAction = UNNotificationAction(identifier: QorumPushIdentifier.beaconsCheckingOutCancelAction.rawValue,
                                                     title: okActionTitle,
                                                     options: [])
            
            let category = UNNotificationCategory(
                identifier: QorumPushIdentifier.beaconsCheckingOutCancel.rawValue,
                actions: [okAction],
                intentIdentifiers: [],
                options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            let body = title + " " + message
            let content = UNMutableNotificationContent.create(with:  venue.name,
                                                              body: body,
                                                              categoryIdentifier: category.identifier)
            VenueTrackerNotifier.showNotification(with: category.identifier, content: content)
        }
    }
    
    /// Creates a local notification that notifies user about payment issues.
    ///
    /// - Parameter venue: relevant venue.
    class func showChangePaymentRequestNotification(for venue: Venue?) {
        let identifier = QorumPushIdentifier.paymentIssueRequest.rawValue
        let content = UNMutableNotificationContent.create(with: nil,
                                                          body: "Tab Failed to Open: Please change your default payment method or add another payment method to open your tab.",
                                                          venue: venue,
                                                          categoryIdentifier: "checkin.payment.category")
        VenueTrackerNotifier.showNotification(with: identifier, content: content)
    }
    
    /// Alert wrapper for requesting auto-checkin option.
    ///
    /// - Parameters:
    ///   - venue: venue to checkin.
    ///   - shouldCheckin: Indicates whether the user wants to open a new tab after auto-checkin option request.
    class func requestAutoOpenTab(_ venue: Venue, shouldCheckin: Bool) {
        let title = "Would you like to turn on auto-checkin to automatically open a tab when you're in the bar?"
        let dismissAction, allowAction: UIAlertController.CustomAction
        dismissAction = ("Dismiss", .cancel, {
            if shouldCheckin { VenueTracker.shared.checkInToVenue(venue) }
        })
        allowAction = ("Allow", .default, {
            UserDefaults.standard.set(true, for: UserDefaultsKeys.autoOpenTabKey)
            if shouldCheckin {
                VenueTracker.shared.checkInToVenue(venue)
            } else {
                LocationService.shared.refreshRanging()
            }
        })
        UIAlertController.presentAsAlert(title: title,
                                         actions: [dismissAction, allowAction])
    }
}
