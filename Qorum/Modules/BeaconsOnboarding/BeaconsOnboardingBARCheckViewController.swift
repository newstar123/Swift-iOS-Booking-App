//
//  BeaconsOnboardingBARCheckViewController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 6/11/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

protocol BOBackgroundRefreshDisplayLogic: class {
    
}

private let kBARIsOnInfoString = """
Keeping Background App Refresh on ensures that Qorum's automatic tab opening and closing features can work even when the Qorum app is backgrounded. This also helps send you updates about your current tab.

Looks like you've currently got it on, so we're golden!
"""

private let kBARIsOffInfoString = """
Make sure that Background App Refresh is on so that Qorum's automatic tab opening and closing features can work even when the Qorum app is backgrounded. This also helps send you updates about your current tab.

Go to ***Settings > General > Background App Refresh*** and check that it says "On".

Note: Background App Refresh might be off if you're on "Low Power Mode".
"""

class BeaconsOnboardingBARCheckViewController: BaseViewController, SBInstantiable {
    
    static let storyboardName = StoryboardName.beaconsOnboarding
    var interactor: BeaconsOnboardingBusinessLogic?
    var router: (NSObjectProtocol & BeaconsOnboardingRoutingLogic & BeaconsOnboardingDataPassing)?
    
    var isBARTurnedOn: Bool = UIApplication.shared.backgroundRefreshStatus == .available
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = BeaconsOnboardingInteractor()
        let presenter = BeaconsOnboardingPresenter()
        let router = BeaconsOnboardingRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.backgroundRefreshController = viewController
        router.refreshController = viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if isBARTurnedOn {
            infoLabel.text = kBARIsOnInfoString
        } else {
            let components = kBARIsOffInfoString.components(separatedBy: "***")
            infoLabel.attributedText = NSMutableAttributedString(
                (components[0], UIFont.montserrat.light(16), .white),
                (components[1], UIFont.montserrat.medium(16), .white),
                (components[2], UIFont.montserrat.light(16), .white)
            )
        }
        settingsButton.isHidden = isBARTurnedOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back() {
        router?.dismiss()
    }
    
    /// Opens device settings
    @IBAction func openSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { success in
                print("Settings opened: \(success)") // Prints true
            }
        }
    }

}

extension BeaconsOnboardingBARCheckViewController: BOBackgroundRefreshDisplayLogic {
    
    
    
}
