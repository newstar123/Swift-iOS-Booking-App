//
//  AppDelegate.swift
//  Qorum Config
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
/// The Application Delegate for Qorum Configurator
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Holds the main `UIWindow` of the app
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    /// Initial setup on app's startup goes here.
    ///
    /// - Parameters:
    ///   - application: Your singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty in situations where the user launched the app directly. For information about the possible keys in this dictionary and how to handle them, see Launch Options Keys.
    /// - Returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true. The return value is ignored if the app is launched as a result of a remote notification.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let mainTVC = MainTableViewController()
        let rootNC = UINavigationController(rootViewController: mainTVC)
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
        Fabric.with([Crashlytics.self])
        return true
    }
    
    /// Synchronizes shared and internal config data.
    ///
    /// - Parameter application: Your singleton app object.
    func applicationWillResignActive(_ application: UIApplication) {
        AppConfig.synchronize()
        ConfigProfile.synchronize()
        CustomLocation.synchronize()
    }
    
}

