//
//  AppDelegate.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let appDependencies = AppDependencies()
    
    var checkinHash: [Int: Checkin] = [:] {
        didSet {
            if checkinHash.values.contains(where: { $0.checkout_time == nil }) {
                VenueTracker.shared.isCheckingIn = false
            }
        }
    }
    
    var freeRideCheckinsHash: [Checkin] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        appDependencies.setupDependenciesForApplication(application, launchOptions: launchOptions)
        UserDefaults.standard.increaseLaunchCount()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        appDependencies.qorumApplicationDidEnterBackground(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        appDependencies.qorumApplicationDidBecomeActive(application)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        AppConfig.synchronize()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.set(false, for: .showBluetoothAccessViewKey)
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return appDependencies.qorumApplication(application,
                                               openURL: url,
                                               sourceApplication: sourceApplication,
                                               annotation: annotation)
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return appDependencies.qorumApplication(app, openURL: url, options: options)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
        return appDependencies.qorumApplication(application,
                                                continue: userActivity,
                                                restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        appDependencies.qorumApplication(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        appDependencies.qorumApplication(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        appDependencies.qorumApplication(application,
                                         didReceiveRemoteNotification: userInfo,
                                         fetchCompletionHandler: completionHandler)
    }
    
    func clearHashedData() {
        checkinHash.removeAll()
        freeRideCheckinsHash.removeAll()
        UserDefaults.standard.set(false, for: .hasActiveCheckin)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.activeCheckinId.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.activeCheckinVenueId.rawValue)
    }

}

