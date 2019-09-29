//
//  VenueTracker.swift
//  Qorum
//
//  Created by Dima Tsurkan on 12/13/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

/// Helper for checkin/checkout with beacons/gps.
class VenueTracker: NSObject {
    
    // MARK: - Shared
    static let shared = VenueTracker()
    
    // MARK: - Properties
    
    /// Defines whether tracker is currently checking in. Used for ignoring redundant checkin calls.
    var isCheckingIn = false
    
    /// Defines whether tracker is currently checking out. Used for ignoring redundant checkout calls.
    var isCheckingOut = false
    
    /// Storage for the venue object that needs for processing.
    var trackedVenue: Venue?
    
    // MARK: - Init
    fileprivate override init() {}
    
    /// Attempts to call VenueTracker's checkOutFromVenue(_: Venue).
    ///
    /// If user hasn't verified his email, this method fails and calls VenueTrackerNotifier.showPhoneVerifyNotif()
    ///
    /// - Parameter venue: represents the venue that user wants to leave.
    func attemptAutoCheckout(to venue: Venue) {
        debugPrint("auto checking out from VenueId:\(venue.venue_id)")
        if User.stored.isPhoneVerified {
            checkOutFromVenue(venue)
        } else {
            VenueTrackerNotifier.showPhoneVerifyNotif()
        }
    }
    
    /// Attempts to call checkInToVenue(_: Venue). Fails if trackedVenue == nil.
    func checkinFromNotif() {
        if let venue = trackedVenue {
            checkInToVenue(venue)
        }
    }
    
    /// Calls checkPreconditions(venue: Venue). Also shows the progress HUD if it's not visible.
    ///
    /// - Parameter venue: venue to checkin.
    func checkInToVenue(_ venue: Venue) {
        if !QorumProgressHUD.isVisible {
            QorumProgressHUD.appearance().style = .black
            QorumProgressHUD.show(withMessage: "Checking preconditions", completion: nil)
        }
        
        isCheckingIn = true
        
        checkPreconditions(venue: venue)
    }
    
    /// Calls VenueDetailsWorker().checkPreconditions(venue: Venue, success: () -> Void, failure: ([String: String]) -> Void).
    ///
    /// - On success: calls openCheckin(_: Venue).
    ///
    /// - On failure: dismisses progress HUD.
    ///
    /// - Parameter venue: venue to checkin.
    func checkPreconditions(venue: Venue) {
        VenueDetailsWorker().checkPreconditions(venue: venue, success: {
            self.openCheckin(venue: venue)
        }) { _ in
            QorumProgressHUD.dismiss()
        }
    }
    
    /// Calls VenueDetailsWorker().openNewCheckIn(venueId: Int, successHandler: (Checkin) -> Void, failureHandler: ([String: Any]) -> Void). Also shows/updates the progress HUD if it's not visible.
    ///
    /// - On success: calls openCheckinSuccess(checkin: Checkin, venue: Venue).
    ///
    /// - On failure: dismisses progress HUD, calls openCheckinError(venue: Venue, errorDict:[String: Any]).
    ///
    /// - Parameter venue: venue to checkin.
    func openCheckin(venue: Venue) {
        let worker = VenueDetailsWorker()
        if !QorumProgressHUD.isVisible {
            QorumProgressHUD.appearance().style = .black
            QorumProgressHUD.show(withMessage: "Opening Tab", completion: nil)
        } else {
            QorumProgressHUD.update(message: "Opening Tab")
        }
        worker.openNewCheckIn(venueId: venue.venue_id, successHandler: { (checkinRes) in
            self.openCheckinSuccess(checkin: checkinRes, venue: venue)
        }) { (errorDict) in
            QorumProgressHUD.dismiss()
            debugPrint(errorDict)
            self.openCheckinError(venue: venue, errorDict: errorDict)
        }
    }
    
    /// Successful checkin request handler.
    ///
    /// This method sends a message to the VenuesViewController to handle successful checkin.
    /// If app is not active, relevant local notification will be shown.
    ///
    /// - Parameters:
    ///   - checkin: checkin object.
    ///   - venue: venue with successful checkin.
    func openCheckinSuccess(checkin: Checkin, venue: Venue) {
        QorumProgressHUD.dismiss()
        self.isCheckingIn = false
        
        if let venuesVC = UINavigationController.root?.find(VenuesViewController.self) {
            venuesVC.interactor?.showCheckinFromBeacon()
        }
        
        if UIApplication.shared.applicationState != .active {
            VenueTrackerNotifier.showCheckedInNotifications(for: venue)
        }
        
        AnalyticsService.shared.track(event: MixpanelEvents.tabOpen.rawValue,
                                      properties: ["Venue": venue.name,
                                                   "Tab Open Method": "Auto-Open with Beacons",
                                                   "Discount": venue.discountValue,
                                                   "Market":venue.market?.name ?? "",
                                                   "Neighborhood":venue.neighborhood ?? ""])
    }
    
    /// Failed checkin request handler.
    ///
    /// This method sends a message to the VenuesViewController to handle failing checkin and show the relevant error.
    ///
    /// - Parameters:
    ///   - venue: venue in which user wanted to open a tab.
    ///   - errorDict: dictionary that may hold possible errors in it.
    func openCheckinError(venue: Venue, errorDict:[String: Any]) {
        guard let rootNC = UINavigationController.root else { return }
        trackedVenue = venue
        let venueDetailsVC = VenueDetailsViewController.fromStoryboard
        var venueDetailsDS = venueDetailsVC.router!.dataStore!
        venueDetailsDS.venue = trackedVenue
        
        var vcsToLeft: [UIViewController] = rootNC.viewControllers.filter { (viewController) -> Bool in
            return viewController is LoadingViewController || viewController is VenuesViewController
        }
        vcsToLeft.append(venueDetailsVC)
        rootNC.viewControllers = vcsToLeft
        
        let viewModel = VenueDetails.CheckIn.ViewModel(checkin: nil, warning: .none, checkinError: errorDict)
        venueDetailsVC.displayCheckinError(viewModel: viewModel)
    }
    
    /// Attemts to close a tab in the given venue.
    ///
    /// This method invokes delayed checkout request rather than immediate checkout.
    /// Userful for checkouts with gps/beacons.
    ///
    /// - Parameter venue: venue in which user wants to close his tab.
    func checkOutFromVenue(_ venue: Venue) {
        let worker = BillWorker()
        let appDelegate = AppDelegate.shared
        
        let activeCheckin = appDelegate.checkinHash.values.first { checkin in
            checkin.checkout_time == nil && checkin.venue?.venue_id == venue.venue_id
        }
        if let checkin = activeCheckin {
            print("Did start checking out from \(venue.name)")
            UserDefaults.standard.set(checkin.checkin_id, forKey: UserDefaultsKeys.delayedCheckinId.rawValue)
            worker.delayedCheckOut(checkinId: checkin.checkin_id) { (result) in
                switch result {
                case .value:
                    VenueTrackerNotifier.notifyOnExitRegion(for: venue)
                case .error(let error):
                    // TODO: Error handling
                    debugPrint(error.localizedDescription)
                }
                self.isCheckingOut = false
            }
        } else if let activeCheckinId = UserDefaults.standard.value(forKey: UserDefaultsKeys.activeCheckinId.rawValue) as? Int {
            print("Did start checking out from \(venue.name)")
            UserDefaults.standard.set(activeCheckinId, forKey: UserDefaultsKeys.delayedCheckinId.rawValue)
            worker.delayedCheckOut(checkinId: activeCheckinId) { (result) in
                switch result {
                case .value:
                    VenueTrackerNotifier.notifyOnExitRegion(for: venue)
                case .error(let error):
                    // TODO: Error handling
                    debugPrint(error.localizedDescription)
                }
                self.isCheckingOut = false
            }
        } else {
            print("Did not start check out from \(venue.name)")
            self.isCheckingOut = false
        }
    }
    
}

