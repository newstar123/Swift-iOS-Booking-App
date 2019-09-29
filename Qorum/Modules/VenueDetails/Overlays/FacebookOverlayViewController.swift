//
//  FacebookOverlayViewController.swift
//  Qorum
//
//  Created by Stanislav on 26.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

/// The object that receives login action.
protocol FacebookOverlayDelegate: class {
    
    /// Login action.
    func connectButtonPressed()
    
}

class FacebookOverlayViewController: UIViewController, SBInstantiable {
    
    /// AKA login button.
    @IBOutlet private weak var connectButton: UIButton!
    
    static let storyboardName = StoryboardName.venueDetails
    
    /// login action receiver.
    weak var delegate: FacebookOverlayDelegate?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        connectButton.setAttributedTitle({
            NSMutableAttributedString(
                ("CONNECT WITH ", UIFont.montserrat.light(14), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                ("FACEBOOK", UIFont.montserrat.bold(14), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            )
        }(), for: .normal)
        
        connectButton.setAttributedTitle({
            NSMutableAttributedString(
                ("CONNECT WITH ", UIFont.montserrat.light(14), #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)),
                ("FACEBOOK", UIFont.montserrat.bold(14), #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1))
            )
        }(), for: .highlighted)
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.removeFromParentController()
    }
    
    /// Passes the login action to the delegate.
    @IBAction func connectButtonPressed(_ sender: Any) {
        delegate?.connectButtonPressed()
    }
    
}
