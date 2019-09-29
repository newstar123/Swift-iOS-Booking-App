//
//  AppDependencies.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import FacebookCore
import UserNotifications
import Fabric
import Crashlytics
import GooglePlaces
import GoogleMaps
import Stripe
import UberRides
import UberCore
import Firebase
import FirebaseMessaging
import Branch
import TwitterKit
import SwiftyJSON
import SwiftyBeaver
import ZendeskSDK
import ZendeskCoreSDK

class AppDependencies: NSObject {
    
    // MARK: - Instance methods
    
    func setupDependenciesForApplication(_ app: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        UNUserNotificationCenter.current().delegate = self
        
        // SwiftyBeaver logging
        let platform = SBPlatformDestination(appID: "Rl1zqm",
                                             appSecret: "pblzFlMmta2A8wn4FjnqnwhaV1nzrFq1",
                                             encryptionKey: "nrgmu1cQ0n8RpiqbxzA6pqWimqm6mf4x")
        SwiftyBeaver.addDestination(platform)
        SwiftyBeaver.setupConsole()
        SwiftyBeaver.setOSLog(enabled: true)
        
        //Fabric/Crashlytics
        Fabric.with([Crashlytics.self])
        
        // TWITTER
        TWTRTwitter.sharedInstance().start(withConsumerKey: SocialServiceKeys.qorumTwitterKey,
                                           consumerSecret: SocialServiceKeys.qorumTwitterSecret)
        UserDefaults.standard.set(false, for: .notificationAccessIgnored)
        showLoadingModule(app)
        
        // GOOGLE
        GMSServices.provideAPIKey(SocialServiceKeys.qorumGMSServicesAPIKey)
        GMSPlacesClient.provideAPIKey(SocialServiceKeys.qorumGMSPlacesClientAPIKey)
        
        // STRIPE
        if AppConfig.stripeSandboxModeEnabled {
            Stripe.setDefaultPublishableKey(SocialServiceKeys.qorumSandboxStripeAPIKey)
        } else {
            Stripe.setDefaultPublishableKey(SocialServiceKeys.qorumStripeAPIKey)
        }
        
        loadAdvert()
        
        // FACEBOOK
        SDKApplicationDelegate.shared.application(app, didFinishLaunchingWithOptions: launchOptions)
        
        // UBER
        _ = UberAppDelegate.shared.application(app, didFinishLaunchingWithOptions: launchOptions)
        
        // If true, all requests will hit the sandbox, useful for testing
        Configuration.shared.isSandbox = AppConfig.uberSandboxModeEnabled
        // If true, Native login will try and fallback to using Authorization Code Grant login (for privileged scopes). Otherwise will redirect to App store
        Configuration.shared.useFallback = false
        
        // Firebase
        FirebaseApp.configure()
        
        let lyftInstalled = UIApplication.shared.canOpenURL(URL(string: "lyft://")!)
        Analytics.setUserProperty("\(lyftInstalled)", forName: "is_lyft_app_available")
        
        // MIXPANEL
        AnalyticsService.shared.setupMixpanel()
        
        // BRANCH
        Branch.setUseTestBranchKey(true)
        
        let branch: Branch = Branch.getInstance()
        
        let branchCallback: callbackWithParams = { (params, error) in
            guard let data = params as? [String: Any] else { return }
            print("Deep link data:\n\(data as NSDictionary)")
            self.parseBranchResponse(data: data, app: app)
        }
        
        branch.initSession(launchOptions: launchOptions ?? [:],
                           isReferrable: true,
                           andRegisterDeepLinkHandler: branchCallback)
        
        // Zendesk
        Zendesk.initialize(appId: SocialServiceKeys.qorumZendeskAppId,
                           clientId: SocialServiceKeys.qorumZendeskClientId,
                           zendeskUrl: SocialServiceKeys.qorumZendeskUrl)
        Support.initialize(withZendesk: Zendesk.instance)
        
        //Tracking beacons
        _ = VenueTracker.shared
        _ = LocationService.shared
        
        // This makes the bluetooth helper to start observing bluetooth state
        let _ = BluetoothHelper.shared
        
        loadMetadata()
        
        CityManager.shared.fetchMarketsData()
        
        if UserDefaults.standard.optionalBool(for: UserDefaultsKeys.autoOpenTabKey) == nil {
            UserDefaults.standard.set(true, for: UserDefaultsKeys.autoOpenTabKey)
        }
        
        checkVersion()
    }
    
    func parseBranchResponse(data: [String: Any], app: UIApplication) {
        UserDefaults.standard.referralCode = data["referral_code"] as? String
        let idJSON = JSON(data)["venue_id"]
        if idJSON.object is NSNull {
            return
        }
        let sharedVenueId = idJSON.intValue
        if let venue = AppRouter.findVenue(with: sharedVenueId) {
            AppRouter.handleSharedVenue(venue, in: app)
            return
        }
        let venueRequest = VenuesRequest(target: .fetchVenue(id: sharedVenueId))
        venueRequest.performDecoding { (result: APIResult<Venue>) in
            switch result {
            case let .value(sharedVenue):
                AppRouter.handleSharedVenue(sharedVenue, in: app)
            case let .error(error):
                print(error)
            }
        }
    }
    
    func checkVersion() {
        let infoDictionary = Bundle.main.infoDictionary
        guard let appId = infoDictionary?["CFBundleIdentifier"] as? String else { return }
        let lookupRequest = ITunesLookupRequest(target: .lookup(id: appId))
        lookupRequest.performDecoding { (result: APIResult<LookupResult>) in
            switch result {
            case let .value(result):
                guard let appStoreVersion = result.version, let currentVersion = infoDictionary?["CFBundleShortVersionString"] as? String else { return }
                print ("Production version: \(appStoreVersion)")
                let digits: Int = max(appStoreVersion.split(separator: ".").count, currentVersion.split(separator: ".").count)
                if appStoreVersion.versionNumber(digits: digits) > currentVersion.versionNumber(digits: digits) {
                    QorumNotification.updateAvailable.post()
                }

            case let .error(error):
                print(error)
            }
        }

        
    }
    
    func requestNotificationsPermissions(application: UIApplication) {
        // Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current()
                .requestAuthorization(options: authOptions, completionHandler: { _, _ in })
            
            // For iOS 10 data message (sent via FCM)
            // Messaging.messaging().remoteMessageDelegate = self
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    // MARK: - Application methods
    
    func qorumApplicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func qorumApplicationDidBecomeActive(_ app: UIApplication)  {
        AppEventsLogger.activate(app)
    }
    
    @objc func loadAdvert() {
        LoadingWorker().fetchAdvert { (result) in
            switch result {
            case let .value(advert):
                advert.save()
            case let .error(error):
                print("AppDelegate.fetchAdvert failure: \(error.localizedDescription)")
                self.perform(#selector(self.loadAdvert), with: nil, afterDelay: 5)
            }
        }
    }
    
    @objc func loadMetadata() {
        LoadingWorker().fetchMetadata { (result) in
            switch result {
            case let .value(metadata):
                metadata.save()
                print("didLoadMetadata")
            case let .error(error):
                print("AppDelegate.fetchMetadata failure: \(error.localizedDescription)")
                self.perform(#selector(self.loadMetadata), with: nil, afterDelay: 5)
            }
        }
    }
    
    func qorumApplication(_ application: UIApplication,
                          openURL url: URL,
                          sourceApplication: String?,
                          annotation: Any) -> Bool {
        var handled: Bool = false
        handled = UberAppDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        if (handled) {
            return true
        }
        
        if let urlComponents = URLComponents(string: url.absoluteString), let _ = urlComponents.queryItems, url.absoluteString.contains("uber_redirect") {
            // return UberAppDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
            if  let token = self.codeFromUrlString(urlString: url.absoluteString),
                let uberOrderVC = UINavigationController.root?.find(UberOrderViewController.self)
            {
                uberOrderVC.authorizeReturn(token)
            }
        }
        
        if (url.scheme?.hasPrefix("fb"))! {
            handled = SDKApplicationDelegate.shared.application(application, open: url, options: [:])
        }
        
        Branch.getInstance().application(application,
                                         open: url,
                                         sourceApplication: sourceApplication,
                                         annotation: annotation)
        return handled
    }
    
    func qorumApplication(_ app: UIApplication,
                          openURL url: URL,
                          options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        var handled: Bool = false
        
        if  let urlComponents = URLComponents(string: url.absoluteString),
            let queryItems = urlComponents.queryItems,
            url.absoluteString.contains("uber_redirect")
        {
            // return UberAppDelegate.shared.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation] as AnyObject)
            
            
            if  let token = self.codeFromUrlString(urlString: url.absoluteString),
                let uberOrderVC = UINavigationController.root?.find(UberOrderViewController.self)
            {
                uberOrderVC.authorizeReturn(token)
            } else if
                let surgeConfirmationId = queryItems.first(where: {$0.name == "surge_confirmation_id"})?.value,
                let uberAdVC = UINavigationController.root?.find(UberAdController.self)
            {
                uberAdVC.uberSurgeConfirmationId = surgeConfirmationId
                uberAdVC.orderUberAfterSurge()
            }
        }
        
        if url.scheme!.hasPrefix("twitter") {
            handled = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        }
        
        if url.scheme!.hasPrefix("fb") {
            handled = SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
        
        Branch.getInstance().application(app, open: url, options: options)
        return handled
    }
    
    func codeFromUrlString(urlString: String) -> String? {
        if urlString.contains("code=") {
            if let range = urlString.range(of: "code=") {
                let cuttedString = urlString.suffix(from: range.upperBound)
                print(cuttedString)
                return String(cuttedString)
            }
        }
        return nil
    }
    
    func qorumApplication(_ application: UIApplication,
                          continue userActivity: NSUserActivity,
                          restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func qorumApplication(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID { result, error in
            if let token = result?.token {
                print("DEVICE TOKEN STR: \(token)")
                Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
                AuthWorker().updateAPNSDeviceToken()
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    if settings.authorizationStatus == .authorized {
                        QorumNotification.registeredForRemoteNotifications.post()
                    }
                }
            } else if let error = error {
                debugPrint(error)
            }
        }
    }
    
    func qorumApplication(_ application: UIApplication,
                          didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("qorumApplication didFailToRegisterForRemoteNotificationsWithError:\n", error)
    }
    
    func qorumApplication(_ application: UIApplication,
                          didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        var notificationInfo = JSON(userInfo)
        let messageJSON = JSON(parseJSON: notificationInfo["message"].stringValue)
        notificationInfo["message"] = messageJSON
        let rawStatus = messageJSON["status"].string ?? "nil"
        let status = APNStatus(rawValue: rawStatus.uppercased())
        print("Did receive remote notification:", rawStatus, "\nJSON:", notificationInfo)
        SwiftyBeaver.debug("Did receive remote notification:", rawStatus)
        if let status = status {
            switch status {
            case .TAB_TICKET_UPDATED:
                didReceiveTabTicketUpdatedNotification(checkin_id: notificationInfo["message"]["checkin_id"].intValue)
            case .TAB_TICKET_CLOSED:
                didReceiveTabTicketClosedNotification(checkin_id: notificationInfo["message"]["checkin_id"].intValue)
            case .PRE_AUTH_FUNDS_ERROR:
                didReceiveTabTicketErrorNotification(checkin_id: notificationInfo["message"]["checkin_id"].intValue)
            case .TAB_TICKET_CLOSED_EMPTY:
                didReceiveTabTicketClosedNotification(checkin_id: notificationInfo["message"]["checkin_id"].intValue)
            case .POS_ERROR_CHECKIN:
                break
            case .POS_ERROR_WITHOUT_CHECKIN:
                break
            case .CURRENT_POS_ERROR:
                break
            case .POS_ERROR_CLOSE_CHECKIN:
                break
            case .ERROR:
                break
            }
        } else {
            let alert = notificationInfo["aps"]["alert"]
            let title = alert["title"].string
            let message = alert["body"].string
            UIAlertController.presentAsAlert(title: title, message: message)
        }
        completionHandler(.newData)
    }
    
    // MARK: - Update Checkin Triggers
    
    private func didReceiveTabTicketUpdatedNotification(checkin_id: Int) {
        guard checkin_id == AppDelegate.shared.checkinHash.values.first?.checkin_id else { return }
        QorumNotification.tabTicketUpdated.post()
    }
    
    private func didReceiveTabTicketClosedNotification(checkin_id: Int) {
        QorumNotification.checkedOut.post()
        guard let checkin = AppDelegate.shared.checkinHash.values.first(where: { $0.checkout_time == nil && $0.checkin_id == checkin_id }) else {
            print("Tab closed: No such checkin stored")
            return
        }
        checkin.checkout_time = Date()
        AppDelegate.shared.checkinHash.updateValue(checkin, forKey: checkin.venue?.venue_id ?? 0)
        let delayedCheckinId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.delayedCheckinId.rawValue)
        let closeMethod = checkin_id == delayedCheckinId ? "Auto-Close with Beacons" : "Manually Closed by Bartender"
        BillWorker().trackClose(venue: checkin.venue, checkin: checkin, method: closeMethod)

        guard let rootNC = UINavigationController.root else { return }
        let presentedVC = rootNC.viewControllers.last?.presentedViewController as? BaseNavigationController
        let containsPresentedBill: Bool = presentedVC?.viewControllers.contains(where: { $0 is BillViewController }) ?? false
        if rootNC.viewControllers.contains(where: { $0 is BillViewController }) || containsPresentedBill {
            QorumNotification.tabTicketClosed.post()
            print("Tab closed: Posted notif")
        } else {
            print("Tab closed: Show closed VC")
            let destinationVC = ClosedTabViewController.fromStoryboard
            UserDefaults.standard.set(false, for: .hasActiveCheckin)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.activeCheckinId.rawValue)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.activeCheckinVenueId.rawValue)
            VenueTracker.shared.trackedVenue = nil
            destinationVC.checkin = checkin
            rootNC.pushViewController(destinationVC, animated: true)
        }
    }
    
    private func didReceiveTabTicketErrorNotification(checkin_id: Int) {
        guard
            let checkin = AppDelegate.shared.checkinHash.values.first(where: { $0.checkout_time == nil }),
            checkin_id == checkin.checkin_id,
            let rootNC = UINavigationController.root else { return }
        if let billVC = rootNC.find(BillViewController.self) {
            if let paymentsVC = rootNC.find(PaymentsViewController.self, where: { billVC.isUnder($0) }) {
                rootNC.popToViewControllerAnimated(paymentsVC) {
                    paymentsVC.display(title: "Your default payment method for your order has been declined.",
                                       message: "Please change your payment method now.")
                }
            } else {
                rootNC.popToViewControllerAnimated(billVC) {
                    if billVC.paymentFailureAlert == .none {
                        QorumNotification.tabTicketUpdated.post()
                    }
                }
            }
        } else {
            let billVC = BillViewController.fromStoryboard
            billVC.router!.dataStore!.checkin = checkin
            rootNC.pushViewController(billVC, animated: true)
        }
    }
    
    // MARK: - Internal
    
    private func showLoadingModule(_ app: UIApplication) {
        app.keyWindow?.rootViewController = LoadingViewController().embeddedInNavigationController
    }
    
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        InstanceID.instanceID().instanceID { result, error in
            if let _ = result?.token {
                // Disconnect previous FCM connection if it exists.
                Messaging.messaging().shouldEstablishDirectChannel = false
                Messaging.messaging().shouldEstablishDirectChannel = true
                print("Connected to FCM.")
            } else if let error = error {
                debugPrint(error)
            }
        }
    }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDependencies: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = JSON(notification.request.content.userInfo)
        print("UserNotificationCenter will present notification with userInfo:\n", userInfo)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionId = QorumPushIdentifier(rawValue: response.actionIdentifier)
        let notificationId = QorumPushIdentifier(rawValue: response.notification.request.identifier)
        if actionId == .beaconsCheckinRequestAction {
            VenueTracker.shared.isCheckingIn = true
            VenueTracker.shared.checkinFromNotif()
            return
        } else if notificationId == .verifyPhone {
            let destinationVC = NumberInputViewController.fromStoryboard.embeddedInNavigationController
            UINavigationController.root?.present(destinationVC, animated: true, completion: nil)
            return
        } else {
            guard
                let checkin = AppDelegate.shared.checkinHash.values.first(where: { $0.checkout_time == nil }) else { return }
            let userInfo = JSON(response.notification.request.content.userInfo)
            let messageJSON = JSON(parseJSON: userInfo["message"].stringValue)
            let statusString = messageJSON["status"].stringValue.uppercased()
            guard
                APNStatus(rawValue: statusString) == .PRE_AUTH_FUNDS_ERROR,
                messageJSON["checkin_id"].intValue == checkin.checkin_id,
                let rootNC = UINavigationController.root else { return }
            let showAlert: (PaymentsViewController) -> () = { paymentsVC in
                paymentsVC.display(title: "Your default payment method for your order has been declined.",
                                   message: "Please change your payment method now.")
            }
            let routeToPayments = {
                let paymentsViewController = PaymentsViewController.fromStoryboard
                rootNC.pushViewControllerAnimated(paymentsViewController) {
                    showAlert(paymentsViewController)
                }
            }
            if let billVC = rootNC.find(BillViewController.self) {
                if let paymentsVC = rootNC.find(PaymentsViewController.self, where: { billVC.isUnder($0) }) {
                    rootNC.popToViewControllerAnimated(paymentsVC) {
                        showAlert(paymentsVC)
                    }
                } else {
                    billVC.paymentFailureAlert?.dismiss(animated: false, completion: nil)
                    billVC.paymentFailureAlert = nil
                    rootNC.popToViewControllerAnimated(billVC) {
                        routeToPayments()
                    }
                }
            } else {
                let billVC = BillViewController.fromStoryboard
                billVC.router!.dataStore!.checkin = checkin
                rootNC.pushViewControllerAnimated(billVC, completion: routeToPayments)
            }
        }
    }
    
}


