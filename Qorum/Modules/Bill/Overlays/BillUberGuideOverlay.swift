//
//  BillUberGuideOverlay.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/13/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

protocol BillUberGuideOverlayDelegate {
    
    func dismissUberOverlay()
}

class BillUberGuideOverlay: UIViewController {
    
    internal var delegate: BillUberGuideOverlayDelegate?
    
    @IBAction func dismissOverlay() {
        delegate?.dismissUberOverlay()
    }
}
