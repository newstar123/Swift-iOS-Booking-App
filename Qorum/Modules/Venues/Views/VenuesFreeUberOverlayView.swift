//
//  VenuesFreeUberOverlayView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 6/20/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import DeviceKit

class VenuesFreeUberOverlayView: UIVisualEffectView {

    var action: (() -> ())?
    
    init(frame: CGRect, action: (() -> ())?, freeUberButton: UIButton) {
        self.action = action
        
        super.init(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))

        self.frame = frame
        self.contentView.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.05098039216, blue: 0.1411764706, alpha: 0.8833422517)

        let instructionsLabel = UILabel()
        instructionsLabel.text = "Your Free Uber is available until 6am.\nJust press this button when you're\nready to request your ride. "
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

        let uberImage = UIButton(frame: freeUberButton.frame)
        uberImage.setBackgroundImage(freeUberButton.currentBackgroundImage, for: UIControlState())
        self.contentView.addSubview(uberImage)

        let rectForArrow = CGRect(x: self.contentView.centerX,
                                  y: gotItButton.frame.maxY + 8,
                                  width: uberImage.frame.minX - self.contentView.centerX,
                                  height: uberImage.frame.midY - gotItButton.frame.maxY + 1)
        
        let arrow = Drawing { context in
            // arrow body, static angle (%), static top-left corner but dynamic bottom-right
            context.setLineWidth(2.0)
            context.setStrokeColor(#colorLiteral(red: 0, green: 0.6980392157, blue: 0.8705882353, alpha: 1))
            context.setFillColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
            context.move(to: .init(x: 5, y: 5))
            let finishPoint = CGPoint(x: rectForArrow.width - 20, y: rectForArrow.height - 25)
            context.addQuadCurve(to: .init(x: finishPoint.x, y: finishPoint.y), control: .init(x: 5, y: rectForArrow.height*0.65))
            context.strokePath()
            // arrow head, is static for all sizes
            context.setFillColor(#colorLiteral(red: 0, green: 0.6980392157, blue: 0.8705882353, alpha: 1))
            context.setStrokeColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
            let posX = finishPoint.x + 0.01
            let posY = finishPoint.y - 1.47
            context.move(to: .init(x: posX + 3.92, y: posY - 7.16))
            context.addCurve(to: .init(x: posX + 7.8, y: posY - 7.16), control1: .init(x: posX + 4.74, y: posY - 8.29), control2: .init(x: posX + 6.31, y: posY - 9.34))
            context.addLine(to: .init(x: posX + 14.86, y: posY + 6.3))
            context.addCurve(to: .init(x: posX + 13.54, y: posY + 9.9), control1: .init(x: posX + 15.44, y: posY + 7.45), control2: .init(x: posX + 15.79, y: posY + 9.4))
            context.addLine(to: .init(x: posX - 2.45, y: posY + 11.87))
            context.addCurve(to: .init(x: posX - 4.47, y: posY + 8.31), control1: .init(x: posX - 3.82, y: posY + 11.87), control2: .init(x: posX - 5.68, y: posY + 11.46))
            context.addLine(to: .init(x: posX + 3.92, y: posY - 7.16))
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
