//
//  AppRouter.swift
//  Qorum
//
//  Created by Stanislav on 14.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

enum AppRouter {
    
    static func findVenue(with id: Int) -> Venue? {
        return CityManager.shared.allVenues.first { $0.venue_id == id }
    }
    
    static func handleSharedVenue(_ sharedVenue: Venue, in app: UIApplication) {
        guard let topMostVC = app.topMostFullScreenViewController else { return }
        if topMostVC.presentedViewController.hasValue {
            topMostVC.dismiss(animated: true) {
                AppRouter.handleSharedVenue(sharedVenue, in: app)
            }
        }
        let findDetails = topMostVC.find(VenueDetailsViewController.self) {
            $0.interactor?.venue?.venue_id == sharedVenue.venue_id
        }
        if let venueDetailsVC = findDetails {
            topMostVC.navigationController?.popToViewController(venueDetailsVC, animated: true)
            return // shared venue already opened
        }
        let venueDetailsVC = VenueDetailsViewController.fromStoryboard
        venueDetailsVC.router?.dataStore?.venue = sharedVenue
        topMostVC.open(viewController: venueDetailsVC)
    }
    
}
