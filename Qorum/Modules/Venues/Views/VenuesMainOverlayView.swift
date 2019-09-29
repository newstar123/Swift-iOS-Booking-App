//
//  VenuesMainOverlayView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 6/18/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import DeviceKit

class VenuesMainOverlayView: UIVisualEffectView {

    var action: (() -> ())?
    
    init(frame: CGRect, action: (() -> ())?, accountButton: UIButton) {
        self.action = action
        
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
        
        self.frame = frame
        self.contentView.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.05098039216, blue: 0.1411764706, alpha: 0.8833422517)
        
        let instructionsLabel = UILabel()
        instructionsLabel.text = "Be sure to keep your Account and\nPayment up to date. Nothing like an\nexpired credit card to kill your vibe."
        instructionsLabel.font = UIFont.montserrat.light(16)
        instructionsLabel.textColor = .white
        instructionsLabel.addPSD(tracking: 30)
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        let bestSize = instructionsLabel.sizeThatFits(CGSize(width: self.bounds.width - 32, height: self.bounds.height))
        instructionsLabel.frame = CGRect(x: 16, y: self.centerY - bestSize.height - 4, width: self.bounds.width - 32, height: bestSize.height)
        
        self.contentView.addSubview(instructionsLabel)
        
        let gotItButton = UIButton(frame: CGRect(x: 16, y: self.centerY + 32, width: self.bounds.width - 32, height: 50))
        gotItButton.setTitle("GOT IT!", for: UIControlState())
        gotItButton.setTitleColor(.white, for: UIControlState())
        gotItButton.backgroundColor = #colorLiteral(red: 0, green: 0.6980392157, blue: 0.8705882353, alpha: 1)
        gotItButton.titleLabel?.font = UIFont.montserrat.medium(14)
        gotItButton.layer.cornerRadius = 5
        gotItButton.addTarget(self, action: #selector(gotItAction), for: .touchUpInside)
        self.contentView.addSubview(gotItButton)
        
        let accountImage = UIButton(frame: accountButton.frame)
        
        let topOffset = UIApplication.shared.safeAreaInsets.top
        
        accountImage.frame.origin.y = topOffset + 10
        accountImage.setImage(accountButton.imageView?.image, for: UIControlState())
        accountImage.imageEdgeInsets = accountButton.imageEdgeInsets
        self.contentView.addSubview(accountImage)
        
        let rectForArrow = CGRect(x: accountImage.frame.maxX + 5,
                                  y: accountImage.origin.y + accountImage.height / 2 - 5,
                                  width: self.contentView.centerX - accountImage.frame.maxX,
                                  height: instructionsLabel.frame.minY - accountImage.frame.maxY - 8)
        
        
        let arrow = Drawing { context in
            // arrow body, static angle (%), static top-left corner but dynamic bottom-right
            context.setLineWidth(2.0)
            context.setStrokeColor(#colorLiteral(red: 0, green: 0.6980392157, blue: 0.8705882353, alpha: 1))
            context.setFillColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
            context.move(to: .init(x: rectForArrow.width, y: rectForArrow.height))
            context.addQuadCurve(to: .init(x: 11.5, y: 8.5), control: .init(x: rectForArrow.width, y: rectForArrow.height * 0.25))
            context.strokePath()
            // arrow head, is static for all sizes
            context.setFillColor(#colorLiteral(red: 0, green: 0.6980392157, blue: 0.8705882353, alpha: 1))
            context.setStrokeColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
            context.move(to: .init(x: 0.38, y: 6.09))
            context.addCurve(to: .init(x: 1.45, y: 2.99), control1: .init(x: 0.02, y: 5.17), control2: .init(x: 0.46, y: 3.64))
            context.addLine(to: .init(x: 11.6, y: 0.08))
            context.addCurve(to: .init(x: 14.05, y: 2.64), control1: .init(x: 13.17, y: 1.45), control2: .init(x: 14.08, y: 1.45))
            context.addLine(to: .init(x: 10.1, y: 14.11))
            context.addCurve(to: .init(x: 6.59, y: 14.63), control1: .init(x: 9.56, y: 15.02), control2: .init(x: 7.88, y: 15.47))
            context.addLine(to: .init(x: 0.38, y: 6.09))
            context.fillPath()
        }
        arrow.frame = rectForArrow
        arrow.masksToBounds = true
        self.contentView.layer.addSublayer(arrow)
        arrow.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func gotItAction() {
        self.action?()
    }
    
}
