//
//  ClosedTabViewController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/4/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SDWebImage

class ClosedTabViewController: BaseViewController, SBInstantiable, BillDataStore {
    
    var checkin: Checkin?
    static let storyboardName = StoryboardName.bill
    @IBOutlet private weak var advertisingImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var uberButton: UIButton!
    @IBOutlet private weak var uberLogo: UIImageView!
    @IBOutlet private weak var uberDiscountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextApperance()
        configureUberApperance()
        let freeRide = checkin?.freeRideCheckin?.ridesafeStatus?.isFreeRideAvailable == true
        if let adPhotoURL = UserDefaults.standard.advertTabClosedPhotoURL(freeRide: freeRide) {
            advertisingImage.sd_setImage(with: adPhotoURL, completed: nil)
        }
        
        checkAutoClosed()
    }
    
    private func configureTextApperance() {
        let title = """
        Tab Closed
        """
        titleLabel.attributedText = NSMutableAttributedString(
            (title, UIFont.montserrat.semibold(37), UIColor.white)
        )
        
        let message: (String, String)
        message.0 = """
        You're all set. Thank you - have a great night.
        Get home safely by booking an
        """
        message.1 = """
         UBER!
        """
        messageLabel.attributedText = NSMutableAttributedString(
            (message.0, UIFont.montserrat.light(16), UIColor.white),
            (message.1, UIFont.montserrat.semibold(16), UIColor.white)
        )
    }
    
    /// Enables free Uber button and configures it depending on current ridesafe status
    private func configureUberApperance() {
        let rideSafeData = checkin?.freeRideCheckin?.rideSafeData ?? .disabled
        debugPrint("rideSafeData:", rideSafeData)
        switch rideSafeData {
        case .enabled(let discount):
            uberDiscountLabel.text = "$\(discount) MAX"
            uberDiscountLabel.isHidden = false
            uberLogo.image = UIImage(named: "free_uber")
        case .waiting, .disabled:
            uberDiscountLabel.isHidden = true
            uberLogo.image = UIImage(named: "paid_uber")
        }
    }
    
    /// Dispays Alert for Auto-closed Tab
    func checkAutoClosed() {
        if checkin?.autoClosed == true {
            UIAlertController.presentAsAlert(title: "Ooops!", message: "Looks like your tab was closed before you got to order anything. Do you want to open a new tab?", actions: [
                    ("Yes", .default, { [weak self] in self?.routeToReopenTab() }),
                    ("No Thanks", .cancel, nil)
                ])
        }
    }
    
    /// Reopens Tab
    func routeToReopenTab() {
        if let venueDetailsVC = navigationController?.find(VenueDetailsViewController.self) {
            venueDetailsVC.isCheckingIn = true
            navigationController?.popToViewController(venueDetailsVC, animated: true)
        } else if let venuesVC = navigationController?.find(VenuesViewController.self) {
            navigationController?.popToViewControllerAnimated(venuesVC) { [weak checkin] in
                if let venue = checkin?.venue {
                    venuesVC.openTab(for: venue, by: nil, controllerId: 3)
                }
            }
        } else {
            routeBack()
        }
    }
    
    @IBAction func routeBack() {
        verifyPhoneIfNeededElse { [weak navigationController] in
            if let viewController = navigationController?.viewControllers
                .first(where: { $0 is VenueDetailsViewController || $0 is VenuesViewController }) {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func openUber() {
        verifyPhoneIfNeededElse { [unowned self] in
            let router = BillRouter()
            router.dataStore = self as BillDataStore
            router.routeToUber(source: self)
        }
    }
    
    /// Opens Phone number verification screen
    ///
    /// - Parameter onVerified: completion block
    func verifyPhoneIfNeededElse(onVerified: @escaping ()->()) {
        guard !User.stored.isPhoneVerified else {
            onVerified()
            return
        }
        let destinationVC = NumberInputViewController.fromStoryboard
        destinationVC.canClose = false
        let navigationVC = destinationVC.embeddedInNavigationController
        present(navigationVC, animated: true, completion: onVerified)
    }
    
}
