//
//  PoolSeatSelectionView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 6/6/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class PoolSeatSelectionView: UIView {
    
    weak var delegate: PoolSeatSelectionViewDelegate?
    
    @IBOutlet weak var oneSeatButton: UIButton!
    @IBOutlet weak var twoSeatButton: UIButton!
    @IBOutlet weak var oneSeatLabel: UILabel!
    @IBOutlet weak var twoSeatLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var oneButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var oneButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var twoButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var twoButtonWidth: NSLayoutConstraint!
    
    var seatsCount: Int = 2
    var discountAmount: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showSelected()
    }
    
    func formattPrice() {
        var type = delegate!.selectedType!
        //@uber_pool_fix (search tag)
        if let typeForOneSeat = delegate!.classes[0].types.first(where: { $0.name.lowercased().contains("pool1") }),
            seatsCount == 1 {
            type = typeForOneSeat
        }
        
        var priceValue = type.estimate!.price
        var discountValue = discountAmount
        
        if let promValue = type.estimate?.breakdown?.promotion?.value {
            discountValue = promValue < 0 ? promValue * -1 : promValue
        }
        
        if let basePrice = type.estimate?.breakdown?.baseFare?.value {
            priceValue = basePrice
        }
        
        if ((delegate?.pageController?.uberController?.freeRide)! == true || type.estimate?.breakdown?.promotion?.value != nil),
            discountValue > 0
        {
            if priceValue <= discountValue {
                priceLabel.text = "FREE"
            } else {
                let discountedPrice = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue - discountValue)
                let initialPrice = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
                
                let priceStr = NSMutableAttributedString()
                
                let discSelectedAttribute = [NSAttributedStringKey.font: UIFont.montserrat.medium(14), NSAttributedStringKey.foregroundColor: UIColor.white]
                let initialSelectedAttribute = [NSAttributedStringKey.font: UIFont.montserrat.medium(12),
                                                NSAttributedStringKey.foregroundColor: UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1.0),
                                                NSAttributedStringKey.strikethroughStyle: 1] as [NSAttributedStringKey : Any]
                
                priceStr.append(NSAttributedString(string: "\(discountedPrice) ", attributes: discSelectedAttribute))
                priceStr.append(NSAttributedString(string: "\(initialPrice) ", attributes: initialSelectedAttribute))
                
                priceLabel.attributedText = priceStr
            }
        } else {
            priceLabel.text = type.estimate!.currencySymbol() + String(format: "%.2f", priceValue)
        }
    }
    
    @IBAction func didSelectAmount(sender: UIButton) {
        seatsCount = sender.tag
        showSelected()
        formattPrice()
    }
    
    func showSelected() {
        if seatsCount == 1 {
            oneSeatButton.setImage(oneSeatButton.imageView?.image?.withRenderingMode(.alwaysOriginal), for: .normal)
            twoSeatButton.setImage(twoSeatButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            oneSeatLabel.textColor = .white
            twoSeatLabel.textColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1)
            oneButtonWidth.constant = 63
            oneButtonHeight.constant = 63
            twoButtonWidth.constant = 55
            twoButtonHeight.constant = 55
        } else if seatsCount == 2 {
            oneSeatButton.setImage(oneSeatButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            twoSeatButton.setImage(twoSeatButton.imageView?.image?.withRenderingMode(.alwaysOriginal), for: .normal)
            oneSeatLabel.textColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1)
            twoSeatLabel.textColor = .white
            oneButtonWidth.constant = 55
            oneButtonHeight.constant = 55
            twoButtonWidth.constant = 63
            twoButtonHeight.constant = 63
        }
    }
    
    @IBAction func didConfirm() {
        guard seatsCount > 0 else { return }
        self.delegate?.didSelectSeatsCount(count: seatsCount)
    }
}

protocol PoolSeatSelectionViewDelegate: NSObjectProtocol {
    
    var selectedType: UberType? { get }
    var classes: [UberClass] { get }
    var pageController: UberTypesPageController! { get }
    
    func didSelectSeatsCount(count: Int)
    
}
