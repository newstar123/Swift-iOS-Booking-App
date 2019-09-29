//
//  GradientView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/20/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

final class GradientView: UIView {
    
    /// gradient colors
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    /// gradient layer
    lazy var gradientLayer: CAGradientLayer = {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        return gradient
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addGradient()
    }
    /// adds gradient
    func addGradient() {
        gradientLayer.removeFromSuperlayer()
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
}
