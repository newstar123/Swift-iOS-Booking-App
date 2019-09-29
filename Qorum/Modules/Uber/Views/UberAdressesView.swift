//
//  UberAdressesView.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/17/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberAdressesView: UIView {
    
    @IBOutlet weak var uberController: UberOrderViewController!
    @IBOutlet weak var resultsController: AddressSearchResultsContainer!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    @IBOutlet weak var topFieldTralling: NSLayoutConstraint!
    @IBOutlet weak var bottomFieldTralling: NSLayoutConstraint!
    @IBOutlet weak var topLocationButton: UIButton!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    var rideType: QorumRideType = .to
    
    var isEditingTop = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.alpha = 0
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        }) { (completed) in
            switch self.rideType {
            case .from:
                self.activate()
            default:
                break
            }
        }
    }
    
    func activate(selectingTop: Bool? = false) {
        let iphoneXFix = UIApplication.shared.safeAreaInsets.top
        
        self.topOffset.constant = 60 + iphoneXFix
        
        self.topLocationButton.isHidden = true
        
        switch self.rideType {
        case .from:
            self.bottomField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.8)
        case .to:
            self.topField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.8)
            self.topFieldTralling.constant = 10
        case .free:
            if selectingTop == true {
                self.topField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.8)
                self.topFieldTralling.constant = 10
            } else {
                self.bottomField.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.8)
            }
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    
    func deactivate() {
        self.topOffset.constant = 0
        
        switch self.rideType {
        case .from:
            if let place = self.uberController.location { self.bottomField.text = place.name }
            self.bottomField.resignFirstResponder()
        case .to:
            if let place = self.uberController.location { self.topField.text = place.name }
            self.topField.resignFirstResponder()
            self.topFieldTralling.constant = 45
        case .free:
            if isEditingTop == true {
                if let place = self.uberController.location { self.topField.text = place.name }
                self.topField.resignFirstResponder()
                self.topFieldTralling.constant = 45
            } else if isEditingTop == false {
                if let place = self.uberController.destinationLocation { self.bottomField.text = place.name }
                self.bottomField.resignFirstResponder()
            }
        }
        uberController.hideAddresses()
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear, animations: {
            self.layoutIfNeeded()
        }) { (completed) in
            self.topLocationButton.isHidden = self.rideType == .from
        }
    }
    
    func setup(for rideType: QorumRideType, venue: Venue) {
        self.rideType = rideType
        self.topLocationButton.isHidden = rideType == .from
        switch rideType {
        case .from:
            self.topField.text = venue.name
            self.topImageView.image = UIImage(named: "uber_qorum_address_icon")
            self.bottomImageView.image = UIImage(named: "uber_point_icon")
        case .to:
            self.bottomField.text = venue.name
            self.topImageView.image = UIImage(named: "uber_point_icon")
            self.bottomImageView.image = UIImage(named: "uber_qorum_address_icon")
        case .free:
            self.topImageView.image = UIImage(named: "uber_point_icon")
            self.bottomImageView.image = UIImage(named: "uber_point_icon")
        }
    }
    
    @IBAction func showMyLocation() {
        if self.rideType != .free {
            uberController.hideTypes()
            uberController.showTypesLoader()
        }
        uberController.setCurrentAddress()
    }
    
    func activeFieldText() -> String? {
        switch self.rideType {
        case .from:
            return bottomField.text
        case .to:
            return topField.text
        case .free:
            return self.isEditingTop ? topField.text : bottomField.text
        }
    }
    
}

extension UberAdressesView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch self.rideType {
        case .from:
            if textField == topField {
                return false
            }
        case .to:
            if textField == bottomField {
                return false
            }
        case .free:
            if uberController.isShowingAddresses {
                self.isEditingTop = textField == topField
                return true
            } else {
                uberController.showAddresses(selectingTop: textField == topField)
                return false
            }
        }
        
        if uberController.isShowingAddresses {
            self.isEditingTop = textField == topField
            return true
        }
        
        uberController.showAddresses()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch self.rideType {
        case .from:
            self.bottomField.selectAll(nil)
        case .to:
            self.topField.selectAll(nil)
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        deactivate()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let str = textField.text as NSString?
        self.resultsController.loadPlacesRequest(text: (str?.replacingCharacters(in: range, with: string))!)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.resultsController.loadPlacesRequest(text: "")
        
        return true
    }
    
}
