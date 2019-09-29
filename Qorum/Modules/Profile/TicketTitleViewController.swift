//
//  TicketTitleViewController.swift
//  Qorum
//
//  Created by D-Link Mac Mini on 10/9/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import ZendeskSDK
import ZendeskCoreSDK
import DeviceKit

class TicketTitleViewController: BaseViewController, SBInstantiable {
    
    static var storyboardName: StoryboardName = .profile
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var containerTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var titleTextField: UITextField! {
        didSet {
            configureTextFieldPadding()
        }
    }
    
    fileprivate var tags: [String] {
        let osVersionTag = "iOS_\(UIDevice.current.systemVersion)"
        let deviceVersionTag = Device().description.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
        
        var tags = [osVersionTag, deviceVersionTag]
        addBuildInfoTag(toTags: &tags)
        addMarketTag(toTags: &tags)
        // addLocationTag(toTags: &tags)
        if let activeCheckin = AppDelegate.shared.checkinHash.values.filter({ $0.checkout_time == nil }).first {
            addVenueTag(fromActiveCheckin: activeCheckin, toTags: &tags)
            // addUberTag(fromActiveCheckin: activeCheckin, toTags: &tags)
        }
        return tags
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func configureView() {
        title = "Add subject title"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        titleTextField.becomeFirstResponder()
    }
    
    /// Configures textfiled's layout
    fileprivate func configureTextFieldPadding() {
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 2.0))
        titleTextField.leftView = leftView
        titleTextField.leftViewMode = .always
    }
    
    /// Updates layout to avoid keyboard's covering
    ///
    /// - Parameter notification: keyboard's notification
    fileprivate func repositionContainer(_ notification: Notification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let yForContainer = (view.height - UIApplication.shared.statusBarFrame.height - navigationView.height - container.height - keyboardRect.height) / 3
            containerTopLayoutConstraint.constant = yForContainer
        }
    }
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        repositionContainer(notification)
    }
    
    /// Adds app's build number to tags
    ///
    /// - Parameter tags: tags array
    fileprivate func addBuildInfoTag(toTags tags: inout [String]) {
        if let qorumBuildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") {
            tags.append("Qorum_build:_\(qorumBuildVersion)")
        }
    }
    
    /// Adds Market info to tags
    ///
    /// - Parameter tags: tags array
    fileprivate func addMarketTag(toTags tags: inout [String]) {
        if let cityName = CityManager.shared.selectedCity?.name {
            tags.append("Market:_\(cityName)")
        }
    }
    
    fileprivate func addLocationTag(toTags tags: inout [String]) {
        if let userCoordinates = LocationService.shared.location?.coordinate {
            tags.append("latitude:_\(userCoordinates.latitude)_longitude:_\(userCoordinates.longitude)")
        }
    }
    
    /// Adds venue with active checkin to tags
    ///
    /// - Parameters:
    ///   - activeCheckin: active checkin
    ///   - tags: tags array
    fileprivate func addVenueTag(fromActiveCheckin activeCheckin: Checkin, toTags tags: inout [String]) {
        if let venueName = activeCheckin.venue?.name {
            tags.append("Checkin_Venue:_\(venueName)")
        }
    }
    
    /// Adds Uber info to tags
    ///
    /// - Parameters:
    ///   - activeCheckin: active checkin
    ///   - tags: tags array
    fileprivate func addUberTag(fromActiveCheckin activeCheckin: Checkin, toTags tags: inout [String]) {
        if let uberCountdown = activeCheckin.ridesafeStatus?.minSpendToRide {
            tags.append("\(uberCountdown)_min_elapsed_on_Uber_countdown")
        }
    }
    
}

extension TicketTitleViewController: UITextFieldDelegate {
    
    /// Submits ticket's title to Zendesk server
    ///
    /// - Parameter textField: acting textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let ident: Identity
        let user = User.stored
        if user.isGuest {
            ident = Identity.createAnonymous()
        } else {
            var username = user.firstName ?? ""
            if let lastName = user.lastName, lastName.isNotEmpty {
                if username.isNotEmpty {
                    username.append(" ")
                }
                username.append(lastName)
            }
            let name = username.isEmpty ? nil : username
            ident = Identity.createAnonymous(name: name, email: user.email)
        }
        Zendesk.instance?.setIdentity(ident)
        let config = RequestUiConfiguration()
        config.subject = textField.text ?? ""
        config.tags = self.tags
        
        let viewController = RequestUi.buildRequestUi(with: [config])
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(viewController, animated: true)
        
        return true
    }
    
}
