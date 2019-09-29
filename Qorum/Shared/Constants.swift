//
//  Constants.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation


/// Networking Debug Behaviour
let kNetworkingDebugBehaviour = QorumNetworkLoggerBehaviour.disabled



/// Amount of minutes to automatic checkout after leaving a venue
let kDelayedCheckoutMinutes = 2

/// Minimal amount for tips
let kTipsMinAmount: Float = 0

/// Maximal amount for tips
let kTipsMaxAmount: Float = 5000




/// Identifier of a Qorum beacon region
let kBeaconsIdentifier = "96F181EB-AB05-4211-BADF-2ACABD7875F3"



/// Image cache url
let kCacheURL = "https://img.gs/ffjbjbvdsh/full/"

/// Privacy-policy url
let kPolicyURL = URL(string: "http://www.qorum.com/privacy-policy-tos")!

/// AppStore url
let kAppStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id1051312647")!




struct AnimationDuration {
    static let Long: TimeInterval = 2
    static let Normal: TimeInterval = 0.30
    static let Short: TimeInterval = 0.15
}

struct SocialServiceKeys {
    static let qorumGMSServicesAPIKey: String = "AIzaSyDERna8G5aTi83apCPXaO8Pk7PmIWRtmFk"
    static let qorumGMSPlacesClientAPIKey: String = "AIzaSyBi8s_4TYO3ZM5ei_NZtLFEb2cgztsplI8"
    static let qorumSandboxStripeAPIKey: String = /*test*/ "pk_test_pMkMWtT8U4h3tYevqMkh0M26"
    static let qorumStripeAPIKey: String = /*prod*/ "pk_live_RDEWKBg6r7B6k74OPr3w4n7v"
    static let qorumUberClientIdKey = "kr_FY1h1pQEzg1srUxSfjqDY_fRPtvgh"
    static let qorumUberClientSecretKey = "IBnF1gv3SsvxgMgRzKBaJNxd8axoq3flZbfrYHHd"
    static let qorumUberServerTokenKey = "BGfgsYcyoRhmnTNy9FUkmYFSjsR1LVg2kXROCxNx"
    static let qorumMixpanelTokenKey = "7ce4ed6db9a70e1ed8e0e85bdb229630"
    static let qorumTwitterKey = "M6NLzXXlkOkEypTVypuB1UHFg"//"AyAkqKgXNhk6hVGSYGiW3JE5W"
    static let qorumTwitterSecret = "B4np5HcYHr5jOePCDEPZyot2tABYKx8SWCsQln7b4UGDI9avsb"//"zHAijpErk7KZcfN9BOTLQfkxBoRYc3iFijnmzAqLk2R4RJvhfV"
    static let qorumCrashlyticsAPIKey = "728450fb2746847a2681c3b2ce6c5d0eac72e476"
    static let qorumZendeskAppId = "D566f42a14871863cb1a3acb23536b15c59e3a0556f62ea9"
    static let qorumZendeskClientId = "Mobile_sdk_client_1a4d341fa6a64876b3d6"
    static let qorumZendeskUrl = "https://qorumhelp.zendesk.com"
}

/// Notification Center Keys
enum QorumNotification: String {
    
    /// Notifies when the selected city is changed.
    case selectedCityChanged = "BaseViewControllerSelectedCityChangedNotification"
    
    /// Notifies when the authorization status for the application changed.
    case locationChanged = "QorumLocationChangedKey"
    
    /// Notifies when the new location data is available.
    case locationUpdated = "locationUpdated"
    
    /// Notifies when the app successfully registered with Apple Push Notification service (APNs).
    case registeredForRemoteNotifications = "didFinishRegisterForRemoteNotifications"
    
    /// Notifies when CBPeripheralManager's state is changed to .poweredOn or .poweredOff
    case bluetoothStatusChanged = "QorumBluetoothStatusChangedNotification"
    
    /// Notifies when the user has successfully sign in
    case userLoggedIn = "QorumUserLoggedInNotification"
    
    /// Notifies when the active ticket updated
    case tabTicketUpdated = "QorumTabTicketUpdatedNotification"
    
    /// Notifies when the active ticket closed
    case tabTicketClosed = "QorumTabTicketClosedNotification"
    
    /// Notifies when the load Checkin with free Uber ride responce received
    case freeRideCheckinsLoaded = "QorumCheckinsWithFreeRideLoaded"
    
    /// Notifies Venue list controller about the need for update checkin rides
    case needsFreeRideCheckinsUpdate = "QorumNeedsFreeRideCheckinsUpdate"
    
    /// Notifies when user has successfully opened a new tab
    case checkedIn
    
    /// Notifies when user has successfully closed his tab
    case checkedOut
    
    /// Notifies Map controller about the need of update of the selected city
    case selectedCityVenuesUpdated
    
    /// Notifies when the cities data in CityManager is updated
    case citiesLoaded
    
    /// Notifies when the cities data in CityManager is failed update
    case citiesLoadFailed
    
    /// Notifies when the new version of the app is available in the AppStore
    case updateAvailable = "QorumUpdateAvailable"
    
    

    var name: Notification.Name {
        return Notification.Name(rawValue)
    }
    
    func post(object: Any? = nil) {
        name.post(object: object)
    }
    
    func add(observer: Any, selector: Selector, object: Any? = nil) {
        name.add(observer: observer, selector: selector, object: object)
    }
    
    func remove(observer: Any, object: Any? = nil) {
        name.remove(observer: observer, object: object)
    }
    
}

/// Push/Local notification identifiers
enum QorumPushIdentifier: String {
    
    /// Checkin with beacon action notification identifier
    case beaconsCheckinRequestAction = "QorumBeaconsCheckinRequestCheckinAction"
    
    /// Delayed checkout notification category identifier
    case beaconsCheckingOutRequest = "QorumBeaconsCheckingOutRequest"
    
    /// Delayed checkout action notification identifier
    case beaconsCheckingOutRequestAction = "QorumBeaconsCheckingOutRequestAction"
    
    /// Delayed checkout canceling notification category identifier
    case beaconsCheckingOutCancel = "QorumBeaconsCheckingOutCancel"
    
    /// Delayed checkout canceling notification identifier
    case beaconsCheckingOutCancelAction = "QorumBeaconsCheckingOutCancelAction"
    
    /// Successful automatic checkin notification identifier
    case beaconsCheckedIn = "QorumBeaconsCheckedInLocalNotification"
    
    /// Verify phone local notification identifier
    case verifyPhone = "QorumVerifyPhoneLocalNotification"
    
    /// Beacon region entrance notification identifier
    case beaconsRangedRegion = "QorumRegionNotif"
    
    /// Payments issue local notification identifier
    case paymentIssueRequest = "QorumPaymentCheckinIssueRequest"
    
    /// Checkin error local notification identifier
    case openCheckinError = "QorumOpenCheckinErrorRequestLocalNotification"
    
    /// Checkout error local notification identifier
    case checkoutError = "QorumCheckoutErrorRequestLocalNotification"
    
    /// Update checkin error local notification identifier
    case updateCheckinError = "QorumUpdateCheckinErrorRequestLocalNotification"
    
    /// Dev mode error notification identifier
    case devModeError = "QorumDevModeError"
}

enum APNStatus: String {
    case
    TAB_TICKET_UPDATED,
    TAB_TICKET_CLOSED,
    PRE_AUTH_FUNDS_ERROR,
    TAB_TICKET_CLOSED_EMPTY,
    POS_ERROR_CHECKIN,
    CURRENT_POS_ERROR,
    POS_ERROR_WITHOUT_CHECKIN,
    POS_ERROR_CLOSE_CHECKIN,
    ERROR
}

/// UserDefaults keys
enum UserDefaultsKeys: String {
    
    /// Represents a boolean value that indicates whether the app was launched for the first time
    case appLaunched = "Application launched"
    
    /// Represents a boolean value that indicates whether the bluetooth access view was shown
    case showBluetoothAccessViewKey = "ShowBluetoothAccessViewKey"
    
    /// Represents a boolean value that indicates whether the user has ignored notification permission access
    case notificationAccessIgnored
    
    /// Represents a boolean value that indicates whether the user has granted location permission access
    case locationAllowedBeforeKey = "LocationAllowedBefore"
    
    /// Represents a boolean value that indicates whether the user has denied location permission access
    case locationRequestedBeforeKey = "LocationRequestedBefore"
    
    /// Represents a boolean value that indicates whether the user has passed age check screen
    case didShowAgeGatingKey = "DidShowAgeGating"
    
    /// Represents a boolean value that indicates whether the onboarding was shown
    case didShowOnboardingKey = "DidShowOnboarding"
    
    /// Represents a boolean value that indicates whether the checkin guide was shown
    case didShowCheckinGuideKey = "DidShowCheckinGuide"
    
    /// Represents a boolean value that indicates whether the show bill guide was shown
    case didShowBillGuideKey = "DidShowBillGuide"
    
    /// Represents a boolean value that indicates whether the facebook overlay was shown for the guest user
    case didShowFacebookOverlayKey = "DidShowFacebookOverlay"
    
    /// Represents a boolean value that indicates whether the autocheckin option enabled in settings
    case autoOpenTabKey = "AutoOpenTab"
    
    /// Represents a boolean value that indicates whether the missing avatar alert was shown
    case didShowNoAvatarAlert = "DidShowNoAvatarAlertKey"
    
    /// Represents a string value that holds an identifier for the uber payments
    case defaultUberPaymentKey = "DefaultUberPaymentMethodKey"
    
    /// Represents a boolean value that indicates whether the user has verified his email or its still pending for verification
    case pendingEmailVerification = "PendingEmailVerificationKey"
    
    /// Represents a boolean value that indicates whether the Always in use location permission prompt was shown
    case didShowAlwaysUseLocationRequest = "DidShowAlwaysUseLocationRequestKey"
    
    /// Represents a date that indicates when the Always in use location permission prompt was shown
    case alwaysUseLocationRequestDate = "AlwaysUseLocationRequestDateKey"
    
    /// Represents a boolean value that indicates whether the user has active checkin or not
    case hasActiveCheckin
    
    /// Represents a boolean value that indicates whether the pull to refresh control was used or the hint is needed to be shown
    case isTabEverPulledToUpdateBill
    
    /// Represents an integer value that indicates the identifier of the checkin that will be closed by region exiting
    case delayedCheckinId
    
    /// Represents an integer value that indicates the identifier of the last checkin with free uber ride
    case lastShownFreeUberRideCheckinId
    
    /// Represents an integer value that indicates the identifier of the active checkin
    case activeCheckinId
    
    /// Represents an integer value that indicates the identifier of the venue associated with the active checkin
    case activeCheckinVenueId
    
    /// The date of the last failed attempt to verify phone.
    case codeInputLastFailedSubmit
    
}

enum MixpanelEvents: String {
    case firstLaunchOfApp = "First Launch of App"
    case submit21BDay = "Submits 21 and Over Bday"
    case viewTutorialScreen1 = "View Tutorial Screen 1"
    case viewTutorialScreen2 = "View Tutorial Screen 2"
    case viewTutorialScreen3 = "View Tutorial Screen 3"
    case viewTutorialScreen4 = "View Tutorial Screen 4"
    case viewLocationPermissionsExplanation = "View Location Permissions Explanation"
    case pressGotItOnLocationPermissions = "Press Got It on Location Permissions Explanation"
    case viewLocationAccessAlert = "View Access Location Alert"
    case respondToLocationAccessAlert = "Respond to Access Location Alert"
    case viewLocationAlwaysAllowAlert = "View Location Always Allow Alert"
    case respondToLocationAlwaysAllowAccessAlert = "Respond to Location Always Allow Alert"
    case viewNotificationPermissionsExplanation = "View Notifications Permissions Explanation"
    case pressGotItOnNotificationsPermissions = "Press Got It on Notifications Permissions Explanation"
    case viewSendNotificationAlert = "View Send Notifications Alert"
    case respondToSendNotificationAlert = "Respond to Send Notifications Alert"
    case viewRegistrationLoginScreen = "View Registration Login Screen"
    case respondToRegistrationLoginScreen = "Respond to Registration Login Screen"
    case viewEmailCaptureScreen = "View Email Capture Screen"
    case submitEmailCaptureScreen = "Submit Email Capture Screen"
    case viewPhoneVerificationScreen = "View Phone Verification Screen"
    case verifyPhoneVerificationSuccess = "Verify Phone Verification Success"
    case registerForAccount = "Register for Account"
    case logIn = "Log In"
    case venueSelected = "Venue Selected"
    case tabOpen = "Tab Open"
    case tabClose = "Tab Close"
    case uberRideRequestSuccess = "Uber Ride Request Success"
    case submitVenueReview = "Submit Venue Review"
    case viewInviteFriendScreen = "View Invite a Friend Screen"
    case inviteAFriend = "Invite a Friend"
}

extension UserDefaults {
    
    func optionalBool(for key: UserDefaultsKeys) -> Bool? {
        return object(forKey: key.rawValue) as? Bool
    }
    
    func bool(for key: UserDefaultsKeys) -> Bool {
        return bool(forKey: key.rawValue)
    }
    
    func set(_ value: Bool, for key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
    }
    
}


