//
//  StoryboardExtensions.swift
//  Qorum
//
//  Created by Stanislav on 29.11.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

enum StoryboardName: String {
    case venues = "Venues"
    case venueDetails = "VenueDetails"
    case map = "Map"
    case profile = "Profile"
    case bill = "Bill"
    case uberOrder = "UberOrderViewController"
    case auth = "Auth"
    case search = "Search"
    case verification = "Verification"
    case beaconsOnboarding = "BeaconsOnboarding"
    case updateAvailable = "UpdateAvailable"
    case locationBlock = "LocationBlock"
}

extension UIStoryboard {
    
    convenience init(_ name: StoryboardName) {
        self.init(name: name.rawValue, bundle: nil)
    }
    
    fileprivate func instantiate<T>(viewController: T.Type) -> T {
        return instantiateViewController(withIdentifier: "\(T.self)") as! T
    }
    
}

protocol UIViewControllerType: NSObjectProtocol { }
extension UIViewController: UIViewControllerType { }

/// The conforming view controller can be instantiated from the storyboard with specified name
protocol SBInstantiable: UIViewControllerType {
    
    /// Owner storyboard name
    static var storyboardName: StoryboardName { get }
    
}

extension SBInstantiable {
    
    /// Returns a view controller instantiated from the owner storyboard
    static var fromStoryboard: Self {
        return UIStoryboard(storyboardName).instantiate(viewController: Self.self)
    }
    
}
