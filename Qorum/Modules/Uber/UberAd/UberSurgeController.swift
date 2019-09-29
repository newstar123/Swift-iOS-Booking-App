//
//  UberSurgeController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 2/16/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import SnapKit

class UberSurgeController: BaseViewController, SBInstantiable {
    
    static let storyboardName = StoryboardName.uberOrder
    
    var href: String?
    
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func configureView() {
        if let href = href {
            let url = URL(string: href)
            let requestObj = URLRequest(url: url!)
            webView.loadRequest(requestObj)
        }
    }
    
    @IBAction func backButtonPressed() {
        let find: (UIViewController.Type) -> UIViewController? = { vcType in
            return self.navigationController?.find(vcType)
        }
        let popTo: (UIViewController) -> () = { viewController in
            self.navigationController?.popToViewController(viewController, animated: true)
        }
        if let uberOrderVC = find(UberOrderViewController.self) {
            popTo(uberOrderVC)
        } else if let venueDetailsVC = find(VenueDetailsViewController.self) {
            popTo(venueDetailsVC)
        } else if let venuesVC = find(VenuesViewController.self) {
            popTo(venuesVC)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}
