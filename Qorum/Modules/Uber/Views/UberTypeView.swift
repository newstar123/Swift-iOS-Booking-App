//
//  UberTypeView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 4/18/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberTypeView: UIView {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var imageCentering: NSLayoutConstraint!
    @IBOutlet weak var nameCentering: NSLayoutConstraint!
    @IBOutlet weak var priceCentering: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var discountAmount: Double = 0
    
    let discSelectedAttribute = [NSAttributedStringKey.font: UIFont.montserrat.medium(13), NSAttributedStringKey.foregroundColor: UIColor.white]
    let initialSelectedAttribute = [NSAttributedStringKey.font: UIFont.montserrat.medium(11),
                                    NSAttributedStringKey.foregroundColor: UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0),
                                    NSAttributedStringKey.strikethroughStyle: 1,
                                    NSAttributedStringKey.baselineOffset: 0] as [NSAttributedStringKey : Any]

    let discDeselectedAttribute = [NSAttributedStringKey.font: UIFont.montserrat.medium(13), NSAttributedStringKey.foregroundColor: UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0)]
    let initialDeselectedAttribute = [NSAttributedStringKey.font: UIFont.montserrat.medium(11),
                                      NSAttributedStringKey.foregroundColor: UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0),
                                      NSAttributedStringKey.strikethroughStyle: 1,
                                      NSAttributedStringKey.baselineOffset: 0] as [NSAttributedStringKey : Any]
    
    var type: UberType = UberType(name: "") {
        didSet {
            nameLabel.text = type.name
            formattPrice()
            if let img = UIImage(named: self.type.name.lowercased()) ?? UIImage(named: "uber_placeholder") {
                image.image = img
            }
        }
    }
    weak var container: UberTypesContainer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareToShow() {
        self.alpha = 0
        imageWidth.constant = 0
        imageHeight.constant = 0
        self.layoutIfNeeded()
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) { 
            self.alpha = 1
        }
        
        imageWidth.constant = 55
        imageHeight.constant = 55
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: { 
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        }
        
        imageWidth.constant = 55
        imageHeight.constant = 55
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    
    func prepareLeft() {
        imageCentering.constant = .deviceWidth - 60
        nameCentering.constant = .deviceWidth - 60
        priceCentering.constant = .deviceWidth - 60
    }
    
    func prepareRight() {
        imageCentering.constant = -(.deviceWidth - 60)
        nameCentering.constant = -(.deviceWidth - 60)
        priceCentering.constant = -(.deviceWidth - 60)
    }
    
    func animateAppearance() {
        appearImage()
        appearLabels()
    }
    
    func appearImage() {
        self.imageCentering.constant = 0
        UIView.animate(withDuration: 0.6, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
                
        }
    }
    
    func appearLabels() {
        self.nameCentering.constant = 0
        self.priceCentering.constant = 0
            
        UIView.animate(withDuration: 0.6, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    
    //MARK: - Selection
    func selectType() {
        guard imageWidth.constant != 63 else { return }
        
        imageWidth.constant = 63
        imageHeight.constant = 63
        UIView.animate(withDuration: 0.4) {
            self.nameLabel.textColor = .white
            self.formattPrice()
            self.layoutIfNeeded()
        }
        
        if let img = UIImage(named: self.type.name.lowercased() + "active") ?? UIImage(named: "uber_placeholderactive") {
            self.image.image = img
        }
        image.layer.add(CATransition(), forKey: kCATransition)
    }
    
    func deselectType() {
        guard imageWidth.constant != 55 else { return }
        
        imageWidth.constant = 55
        imageHeight.constant = 55
        UIView.animate(withDuration: 0.4) {
            self.nameLabel.textColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0)
            self.formattPrice()
            self.layoutIfNeeded()
        }

        if let img = UIImage(named: self.type.name.lowercased()) ?? UIImage(named: "uber_placeholder") { image.image = img }
        image.layer.add(CATransition(), forKey: kCATransition)
    }
    
    func formattPrice() {
        var priceValue = type.estimate!.price
        var discountValue = discountAmount
        
        if let promValue = type.estimate?.breakdown?.promotion?.value {
            discountValue = promValue < 0 ? promValue * -1 : promValue
        }
    
        if let basePrice = type.estimate?.breakdown?.baseFare?.value {
            priceValue = basePrice
        }
        
        if let uberController = container?.controller?.uberController,
            (uberController.freeRide == true || type.estimate?.breakdown?.promotion?.value != nil),
            discountValue > 0
        {
            if priceValue <= discountValue {
                priceLabel.text = "FREE"
                priceLabel.textColor = imageWidth.constant == 55 ? UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0) : .white
            } else {
                let discountedPrice = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue - discountValue)
                let initialPrice = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
                
                let priceStr = NSMutableAttributedString()
                priceStr.append(NSAttributedString(string: "\(discountedPrice) ", attributes: imageWidth.constant == 55 ? discDeselectedAttribute : discSelectedAttribute))
                priceStr.append(NSAttributedString(string: "\(initialPrice) ", attributes: imageWidth.constant == 55 ? initialDeselectedAttribute : initialSelectedAttribute))
                priceLabel.attributedText = priceStr
            }
        } else {
            priceLabel.text = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
            priceLabel.textColor = imageWidth.constant == 55 ? UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0) : .white
        }
    }
    
    @IBAction func selectAction() {
        container?.didSelect(type: type)
    }

}

