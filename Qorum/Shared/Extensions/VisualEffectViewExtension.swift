//
//  VisualEffectViewExtension.swift
//  Qorum
//
//  Created by Vadym Riznychok on 2/5/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import VisualEffectView

extension VisualEffectView {
    
    @IBInspectable var blrRadius: CGFloat {
        set {
            blurRadius = newValue
        }
        get {
            return blurRadius
        }
    }
    
    @IBInspectable var clrTint: UIColor? {
        set {
            colorTint = newValue
        }
        get {
            return colorTint
        }
    }
    
    @IBInspectable var clrTintAlpha: CGFloat {
        set {
            colorTintAlpha = newValue
        }
        get {
            return colorTintAlpha
        }
    }
    
}
