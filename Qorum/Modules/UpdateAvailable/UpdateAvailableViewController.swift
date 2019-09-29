//
//  UpdateAvailableViewController.swift
//  Qorum
//
//  Created by Sergiy Kostrykin on 11/1/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

class UpdateAvailableViewController: BaseViewController, SBInstantiable {

    static let storyboardName = StoryboardName.updateAvailable

    //MARK: - Actions
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        openAppStore()
    }

    /**
     * Opens an App Store Qorum page so user able
     * to download the lastest build.
     */
    private func openAppStore() {
        if UIApplication.shared.canOpenURL(kAppStoreURL) {
            UIApplication.shared.open(kAppStoreURL, options: [:], completionHandler: nil)
        }
    }
}
