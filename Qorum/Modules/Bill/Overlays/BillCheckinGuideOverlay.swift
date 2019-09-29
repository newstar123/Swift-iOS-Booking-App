//
//  BillCheckinGuideOverlay.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/13/18.
//  Copyright © 2018 Qorum. All rights reserved.
//

import UIKit

protocol BillCheckinGuideOverlayDelegate {
    
    func dismissCheckinOverlay()
}

class BillCheckinGuideOverlay: UIViewController {
    
    internal var delegate: BillCheckinGuideOverlayDelegate?
    
    @IBAction func dismissOverlay() {
        delegate?.dismissCheckinOverlay()
    }
}
