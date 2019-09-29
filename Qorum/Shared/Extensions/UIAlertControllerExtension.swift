//
//  UIAlertControllerExtension.swift
//  Qorum
//
//  Created by Sergey Sivak on 1/31/18.
//  Copyright © 2018 Qorum. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    typealias CustomAction = (String, UIAlertActionStyle, (() -> Void)?)
    
    /// Presents alert with selected style
    ///
    /// - Parameters:
    ///   - alertStyle: alert style
    ///   - title: alert title
    ///   - message: alert messgae
    ///   - actions: alert actions
    /// - Returns: alert instance
    @discardableResult
    private static func present(alertStyle: UIAlertControllerStyle,
                                title: String?,
                                message: String?,
                                actions: [CustomAction]) -> UIAlertController? {
        guard alertStyle != .alert || title != .none || message != .none else {
            debugPrint("UIAlertController with alert style should have at least title or message.")
            return nil
        }
        let localizedTitle = title != .none ? NSLocalizedString(title!, comment: .init()) : .none as String?
        let localizedMessage = message != .none ? NSLocalizedString(message!, comment: .init()) : .none as String?
        let blurView = UIView.alertBlurOverlay()
        let alert = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: alertStyle)
        actions.forEach { title, style, completion in
            let localizedActionTitle = NSLocalizedString(title, comment: .init())
            let action = UIAlertAction(title: localizedActionTitle, style: style) { _ in
                DispatchQueue.main.async {
                    blurView.removeFromSuperviewAnimated(duration: AnimationDuration.Short, completion: completion)
                }
            }
            alert.addAction(action)
        }
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        let alertRootVC = UIViewController()
        alertRootVC.view.addSubview(blurView)
        alertWindow.rootViewController = alertRootVC
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertRootVC.present(alert, animated: true, completion: nil)
        return alert
    }
    
    /// Helper method for displaying UIAlertController with preferredStyle UIAlertControllerStyle.alert
    /// Can hanlde both raw strings and localized keys as title and message.
    ///
    /// - Parameters:
    ///   - title: Raw value or localization key for displaying text in title section of alert
    ///   - message: Raw value or localization key for displaying text in message section of alert
    ///   - actions: Actions to be added to alert.
    /// Not specifing this parameter or specifying an empty array is treated as "OK" action with dismiss functionality.
    /// Title for action can be either raw value or localization key.
    /// - Returns: Instance of alert if it is created and presented from seperate `UIWindow`
    @discardableResult
    static func presentAsAlert(title: String? = .none,
                               message: String? = .none,
                               actions: [CustomAction] = [(title: "OK",
                                                           style: .cancel,
                                                           handler: .none)]) -> UIAlertController? {
        return present(alertStyle: .alert, title: title, message: message, actions: actions)
    }
    
    /// Helper method for displaying UIAlertController with preferredStyle UIAlertControllerStyle.actionSheet
    /// Can hanlde both raw strings and localized keys as title and message.
    ///
    /// - Parameters:
    ///   - title: Raw value or localization key for displaying text in title section of alert
    ///   - message: Raw value or localization key for displaying text in message section of alert
    ///   - actions: Actions to be added to alert.
    /// Not specifing this parameter or specifying an empty array is treated as "OK" action with dismiss functionality.
    /// Title for action can be either raw value or localization key.
    /// - Returns: Instance of action sheet if it is created and presented from seperate `UIWindow`
    @discardableResult
    static func presentAsActionSheet(title: String? = .none,
                                     message: String? = .none,
                                     from sender: UIViewController? = .none,
                                     actions: [CustomAction]) -> UIAlertController? {
        return present(alertStyle: .actionSheet, title: title, message: message, actions: actions)
    }
    
}

extension Array where Element == UIAlertController.CustomAction {
    static var noActions: [Element] { return [] }
}

