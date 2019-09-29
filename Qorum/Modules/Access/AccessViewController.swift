//
//  AccessViewController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 10/6/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SnapKit
import UserNotifications
import DeviceKit

enum AccessState: String {
    case locationUndefined = "Qorum uses your current location\nto find bars near you, access your tab,\nand order rides."
    case locationAllowedBefore = "Where you at?***\n\nQorum needs to know your location in order to suggest bars near you, access your bar tab, and order your rides.\n\nGo to ***Settings > Privacy > Location Services >*** Make sure \"Location Services\" are toggled on and location access for Qorum are set to \"While Using\"."
    case locationDeniedBefore = "Where you at?***\n\nQorum needs to know your location in order to suggest bars near you, access your bar tab, and order your rides.\n\nGo to ***Settings > Privacy > Location Services >*** Scroll down to Qorum and select \"While Using\" to make sure Location Services access is allowed."
    case locationDenied = "Where you at?***\n\nQorum needs to know your location in order to suggest bars near you, access your bar tab, and order your rides.\n \nGo to ***Settings > Privacy > Location Services*** and toggle \"Location Services\" on."
    case notificationsUndefined = "Turn on notifications to receive\nbar tab and Uber updates"
    case notificationsDenied = "Enable Notifications to get updates\non your bar tab and Uber status.\n\nWe’ll never spam you. We promise."
    case bluetooth = "Enable Bluetooth, so Qorum can automatically open your tab when you enter the venue and close your tab when you leave.\n\n1. Swipe up from the bottom of your screen to display the Control Center.\n2. Tap the Bluetooth icon "
}

class AccessViewController: BaseViewController {
    
    /// Predefined text for labels
    let settingsButtonTitle = "UPDATE MY SETTINGS"
    let requestButtonTitle = "GOT IT"
    let bluetoothSettingsInfo = "Enable Bluetooth, so Qorum can automatically open your tab when you enter the venue and close your tab when you leave.\n\n"
    let bluetoothSettingsRules = "1. Swipe up from the bottom of your screen to display the Control Center.\n2. Tap the Bluetooth icon "
    let bluetoothSettingsRulesDown = "1. Swipe down from the top right of your screen to display the Control Center.\n2. Tap the Bluetooth icon "
    let bluetoothSettingsInfoDown = "Enable Bluetooth, so Qorum can automatically open your tab when you enter the venue and close your tab when you leave.\n\n"
    
    /// Attributed text for iPhone 8 and earlier models
    lazy var bluetoothInstructionsFoCommonIphoneos: NSAttributedString = {
        let text = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let image = #imageLiteral(resourceName: "bluetooth_icon")
        
        let attributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.montserrat.light(16),
            .paragraphStyle: paragraphStyle
        ]
    
        text.append(.init(string: "Enable Bluetooth ", attributes: [.font : UIFont.montserrat.light(16)]))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "bluetooth_icon"), aligningFont: UIFont.montserrat.light(16))))
        text.append(.init(string: " ,so Qorum can automatically open your tab when you enter the venue and close your tab when you leave.\n\n", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "Step_1"))))
        text.append(.init(string: "\n\nSwipe up from the bottom of your screen to display the Control Center.\n\n", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "Step_2"))))
        text.append(.init(string: "\n\nTap on the Bluetooth icon ", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "bluetooth_icon"), aligningFont: UIFont.montserrat.light(16))))
        text.append(.init(string: " to enable it.", attributes: attributes))
        
        return text
    }()
    
    /// Attributed text for iPhone X and above
    lazy var bluetoothInstructionsFoIphoneX: NSAttributedString = {
        let text = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let image = #imageLiteral(resourceName: "bluetooth_icon")
        
        let attributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.montserrat.light(16),
            .paragraphStyle: paragraphStyle
        ]
        
        text.append(.init(string: "Enable Bluetooth ", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "bluetooth_icon"), aligningFont: UIFont.montserrat.light(16))))
        text.append(.init(string: " ,so Qorum can automatically open your tab when you enter the venue and close your tab when you leave.\n\n", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "Step_1"))))
        text.append(.init(string: "\n\nSwipe down from the top right of your screen to display the Control Center.\n\n", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "Step_2"))))
        text.append(.init(string: "\n\nTap on the Bluetooth icon ", attributes: attributes))
        text.append(.init(attachment: .init(image: #imageLiteral(resourceName: "bluetooth_icon"), aligningFont: UIFont.montserrat.light(16))))
        text.append(.init(string: " to enable it.", attributes: attributes))
        
        return text
    }()
    
    /// current access state
    var state: AccessState?
    
    /// text label with access state description
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.centerY.equalTo(view.snp.centerY)
        }
        return label
    }()
    
    /// GOT IT button
    lazy var button: UIButton = {
        let butt = UIButton(type: .custom)
        butt.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        butt.titleLabel?.font = UIFont.montserrat.medium(14)
        butt.backgroundColor = #colorLiteral(red: 0, green: 0.6980392157, blue: 0.8705882353, alpha: 1)
        butt.tintColor = .white
        butt.titleLabel?.textColor = .white
        butt.layer.cornerRadius = 5
        self.view.addSubview(butt)
        butt.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-5)
            } else {
                make.bottom.equalTo(view.snp.bottomMargin).offset(-5)
            }
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(50)
        }
        return butt
    }()
    
    /// Close button
    lazy var closeButton: UIButton = {
        let butt = UIButton(type: .custom)
        butt.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        butt.setImage(#imageLiteral(resourceName: "Close-X"), for: .normal)
        butt.imageView?.contentMode = .scaleAspectFit
        butt.layer.borderColor = UIColor.accessButtonBorderColor.cgColor
        
        view.addSubview(butt)
        butt.snp.makeConstraints { make in
            if #available(iOS 11, *), !Device().hasHomeButton {
                let margin = view.safeAreaLayoutGuide.snp.topMargin
                if Device().hasHomeButton {
                    make.top.equalTo(margin).offset(5)
                } else {
                    make.top.equalTo(margin).offset(-8)
                }
            } else {
                make.top.equalTo(view.snp.topMargin).offset(5)
            }
            make.leading.equalTo(0)
            make.height.width.equalTo(48)
        }
        return butt
    }()
    
    /// Animated arrows view
    lazy var controlHint: ArrowsView = {
        let loader = ArrowsView()
        view.addSubview(loader)
        return loader
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Notification.Name.UIApplicationDidBecomeActive
            .add(observer: self, selector: #selector(updateAccessStates))
        QorumNotification.bluetoothStatusChanged
            .add(observer: self, selector: #selector(bluetoothStatusChanged))
        updateAccessStates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Notification.Name.UIApplicationDidBecomeActive.remove(observer: self)
    }
    
    //MARK: - Config
    func configureView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.05098039216, blue: 0.1411764706, alpha: 0.7037938784)
        self.view.insertSubview(view, at: 1)
    }
    
    /// Updates UI
    func updateView() {
        closeButton.isHidden = true
        switch state! {
        case .locationUndefined:
            AnalyticsService.shared.track(event: MixpanelEvents.viewLocationPermissionsExplanation.rawValue)
            infoLabel.attributedText = NSMutableAttributedString(
                (state!.rawValue, UIFont.montserrat.light(16), .white)
            )
            button.setTitle(requestButtonTitle, for: .normal)
            infoLabel.snp.updateConstraints({ make in
                make.centerY.equalTo(view.snp.centerY).offset
            })
        case .locationAllowedBefore:
            let components = state!.rawValue.components(separatedBy: "***")
            infoLabel.attributedText = NSMutableAttributedString(
                (components[0], UIFont.montserrat.semibold(26), .white),
                (components[1], UIFont.montserrat.light(16), .white),
                (components[2], UIFont.montserrat.medium(16), .white),
                (components[3], UIFont.montserrat.light(16), .white)
            )
            button.setTitle(settingsButtonTitle, for: .normal)
            infoLabel.snp.updateConstraints({ make in
                make.centerY.equalTo(view.snp.centerY).offset(-16)
            })
        case .locationDenied:
            let components = state!.rawValue.components(separatedBy: "***")
            infoLabel.attributedText = NSMutableAttributedString(
                (components[0], UIFont.montserrat.semibold(26), .white),
                (components[1], UIFont.montserrat.light(16), .white),
                (components[2], UIFont.montserrat.medium(16), .white),
                (components[3], UIFont.montserrat.light(16), .white)
            )
            button.setTitle(settingsButtonTitle, for: .normal)
        case .locationDeniedBefore:
            infoLabel.attributedText = {
                let components = state!.rawValue.components(separatedBy: "***")
                let attributed = NSMutableAttributedString(
                    (components[0], UIFont.montserrat.semibold(26), .white),
                    (components[1], UIFont.montserrat.light(16), .white),
                    (components[2], UIFont.montserrat.medium(16), .white),
                    (components[3], UIFont.montserrat.light(16), .white)
                )
                
                return attributed
            }()
            button.setTitle(settingsButtonTitle, for: .normal)
        case .notificationsUndefined:
            AnalyticsService.shared.track(event: MixpanelEvents.viewNotificationPermissionsExplanation.rawValue)
            infoLabel.attributedText = NSMutableAttributedString(
                (state!.rawValue, UIFont.montserrat.light(16), .white)
            )
            button.setTitle(requestButtonTitle, for: .normal)
        case .notificationsDenied:
            infoLabel.attributedText = NSMutableAttributedString(
                (state!.rawValue, UIFont.montserrat.light(16), .white)
            )
            closeButton.isHidden = false
            button.setTitle(settingsButtonTitle, for: .normal)
        case .bluetooth:
            closeButton.isHidden = false
            if #available(iOS 11, *), !Device().hasHomeButton {
                infoLabel.attributedText = bluetoothInstructionsFoIphoneX
                controlHint.transform = CGAffineTransform(rotationAngle: .pi)
                controlHint.snp.remakeConstraints { make in
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(5)
                    make.trailing.equalTo(-20)
                    make.width.equalTo(40)
                    make.height.equalTo(54)
                }
            } else {
                infoLabel.attributedText = bluetoothInstructionsFoCommonIphoneos
                controlHint.transform = CGAffineTransform(rotationAngle: 0)
                controlHint.snp.remakeConstraints { make in
                    make.bottom.equalTo(view.snp.bottom).offset(-20)
                    make.centerX.equalTo(view.snp.centerX)
                    make.width.equalTo(40)
                    make.height.equalTo(54)
                }
            }
        }
    }
    
    /// Checks for access status update and handles it
    @objc func updateAccessStates() {
        guard state != .bluetooth  else {
            updateView()
            return
        }
        guard LocationService.shared.isLocationEnabled else {
            if LocationService.shared.isLocationUndetermined {
                state = .locationUndefined
            } else {
                if UserDefaults.standard.bool(for: .locationAllowedBeforeKey) {
                    state = .locationAllowedBefore
                } else if UserDefaults.standard.bool(for: .locationRequestedBeforeKey) {
                    state = .locationDeniedBefore
                } else {
                    state = .locationDenied
                }
            }
            updateView()
            return
        }
        LocationService.shared.requestFastestLocationUpdate()
        UserDefaults.standard.set(true, for: .locationAllowedBeforeKey)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.state = .notificationsUndefined
            } else if settings.authorizationStatus == .denied {
                AnalyticsService.shared.track(event: MixpanelEvents.respondToSendNotificationAlert.rawValue, properties: ["Response":"Don’t Allow"])
                self.state = .notificationsDenied
            } else {
                AnalyticsService.shared.track(event: MixpanelEvents.respondToSendNotificationAlert.rawValue, properties: ["Response":"Allow"])
                DispatchQueue.main.async {
                    self.close()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    /// Handles Bluetooth status update
    @objc func bluetoothStatusChanged() {
        if BluetoothHelper.shared.state == .poweredOn {
            close()
        }
    }
    
    /// Removes observers for notifications
    func removeAccessNotif() {
        QorumNotification.locationChanged.remove(observer: self)
        QorumNotification.registeredForRemoteNotifications.remove(observer: self)
    }
    
    //MARK: - Actions
    
    /// Handles GOT IT button action
    @objc func buttonTapped() {
        removeAccessNotif()
        switch state! {
        case .locationUndefined:
            AnalyticsService.shared.track(event: MixpanelEvents.pressGotItOnLocationPermissions.rawValue)
            QorumNotification.locationChanged.add(observer: self,
                                                  selector: #selector(locationAccessGranted))
            LocationService.shared.requestFastestLocationUpdate()
        case .locationAllowedBefore:
            showAppSettings()
        case .locationDenied:
            showAppSettings()
        case .locationDeniedBefore:
            showAppSettings()
        case .notificationsUndefined:
            AnalyticsService.shared.track(event: MixpanelEvents.pressGotItOnNotificationsPermissions.rawValue)
            QorumNotification.registeredForRemoteNotifications
                .add(observer: self, selector: #selector(notificationsAccessGranted(notif:)))
            requestNotificationPermissions()
        case .notificationsDenied:
            showAppSettings()
        case .bluetooth:
            button.isEnabled = false
            self.dismiss(animated: true, completion: nil)
            UserDefaults.standard.set(true, for: .showBluetoothAccessViewKey)
        }
    }
    
    /// Handles close button action
    @objc func closeButtonTapped() {
        switch state {
        case .bluetooth?:
            UserDefaults.standard.set(true, for: .showBluetoothAccessViewKey)
        case .notificationsDenied?:
            UserDefaults.standard.set(true, for: .notificationAccessIgnored)
        default:
            break
        }
        close()
    }
    
    /// Closes alert controller
    func close() {
        NotificationCenter.default.removeObserver(self)
        
        if let vcs = navigationController?.viewControllers, vcs.count > 1 {
            navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Opens iPhone Settings
    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                print("Settings opened: \(success)") // Prints true
            }
        }
    }
    
    /// Asks user to enable Push Notificaations service
    func requestNotificationPermissions() {
        AnalyticsService.shared.track(event: MixpanelEvents.viewSendNotificationAlert.rawValue)
        let app = UIApplication.shared
        (app.delegate as! AppDelegate).appDependencies.requestNotificationsPermissions(application: app)
    }
    
    /// Checks for Notification permissions enabled
    /// SS: Unused, probably replaced by notificationsAccessGranted(_) func
    @objc func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    self.close()
                }
            }
        }
    }
    
    
    /// Handles Using Location Permissions Granted Notification
    @objc func locationAccessGranted() {
        let locationService = LocationService.shared
        if locationService.isLocationEnabled {
            AnalyticsService.shared.track(event: MixpanelEvents.respondToLocationAccessAlert.rawValue, properties: ["Response":"Allow"])
            UserDefaults.standard.set(true, for: .locationAllowedBeforeKey)
        } else if locationService.isLocationDisabled {
            AnalyticsService.shared.track(event: MixpanelEvents.respondToLocationAccessAlert.rawValue, properties: ["Response":"Don’t Allow"])
            UserDefaults.standard.set(true, for: .locationRequestedBeforeKey)
        }
        updateAccessStates()
    }
    
    /// Handles Push Notifications Permissions Enabled
    ///
    /// - Parameter notif: notification to handle
    @objc func notificationsAccessGranted(notif: NSNotification) {
        DispatchQueue.main.async {
            if Device().isSimulator {
                self.close()
            } else {
                self.updateAccessStates()
            }
        }
    }
    
}
