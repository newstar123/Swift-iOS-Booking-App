//
//  LegalNoteViewController.swift
//  Qorum
//
//  Created by Stanislav on 09.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class LegalNoteViewController: BaseViewController, SBInstantiable {
    
    static let storyboardName = StoryboardName.profile
    
    // MARK: - Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
