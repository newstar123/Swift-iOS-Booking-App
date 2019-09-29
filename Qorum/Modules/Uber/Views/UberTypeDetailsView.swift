//
//  UberTypeDetailsView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/12/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberTypeDetailsView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottDistance: NSLayoutConstraint!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var textTopDistance: NSLayoutConstraint!
    @IBOutlet weak var imageX: NSLayoutConstraint!
    @IBOutlet weak var imageY: NSLayoutConstraint!
    @IBOutlet weak var buttonBottDistance: NSLayoutConstraint!
    
    var type: UberType?
    var freeRide: Bool = false
    var discountAmount: Double = 0
    var imageStartPos: CGPoint?
    var selectedImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let iphoneXFix = UIApplication.shared.safeAreaInsets.bottom
        buttonBottDistance.constant = 15 + iphoneXFix
    }
    
    func positionImage(image: UIImageView) {
        selectedImageView = image
        imageView.image = image.image
        
        imageStartPos = image.convert(image.frame.origin, to: self)
        
        imageX.constant = -1*(.deviceWidth/2 - imageStartPos!.x) + 8
        imageY.constant = imageStartPos!.y - 8
        self.layoutIfNeeded()
        
        imageView.isHidden = false
    }
    
    func animateAppereance() {
        imageX.constant = 0
        imageY.constant = 40
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
        
        textTopDistance.constant = 140
        UIView.animate(withDuration: 0.1, delay: 0.7, options: .curveLinear, animations: {
            self.layoutIfNeeded()
            self.textContainer.alpha = 1.0
        }) { (completed) in
            
        }
    }
    
    func showWithType(type: UberType) {
        self.type = type
        self.nameLabel.text = type.name
        self.detailsLabel.text = type.productData!.name_description
        
        var priceValue = type.estimate!.price
        var discountValue = discountAmount
        
        if let promValue = type.estimate?.breakdown?.promotion?.value {
            discountValue = promValue < 0 ? promValue * -1 : promValue
        }
        
        if let basePrice = type.estimate?.breakdown?.baseFare?.value {
            priceValue = basePrice
        }
        
        self.fareLabel.text = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
        if (freeRide == true || type.estimate?.breakdown?.promotion?.value != nil), discountAmount > 0 {
            if type.estimate!.price <= discountValue {
                self.fareLabel.text = "FREE"
            } else {
                let discountedPrice = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue - discountValue)
                let initialPrice = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
                
                let priceStr = NSMutableAttributedString()
                priceStr.append(NSAttributedString(string: "\(discountedPrice) ", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white]))
                priceStr.append(NSAttributedString(string: "\(initialPrice) ", attributes: [NSAttributedStringKey.font: self.fareLabel.font.withSize(10),
                                                                                            NSAttributedStringKey.foregroundColor: UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0),
                                                                                            NSAttributedStringKey.strikethroughStyle: 1,
                                                                                            NSAttributedStringKey.baselineOffset: 0]))
                self.fareLabel.attributedText = priceStr
            }
        } else {
            self.fareLabel.text = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
        }
        self.capacityLabel.text = String(describing: type.productData!.capacity!)
    }
    
    @IBAction func hide() {
        let iphoneXFix =  UIApplication.shared.safeAreaInsets.bottom
        bottDistance.constant = -1 * (462 + iphoneXFix)
        imageX.constant = -1*(.deviceWidth/2 - imageStartPos!.x) + 8
        imageY.constant = imageStartPos!.y - 8
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear, animations: {
            self.superview!.layoutIfNeeded()
        }) { (completed) in
            self.imageView.isHidden = true
            self.selectedImageView?.isHidden = false
        }
        
        textTopDistance.constant = 82.25
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.superview!.layoutIfNeeded()
            self.textContainer.alpha = 0
        }) { (completed) in
            
        }
    }

}
