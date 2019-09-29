//
//  PhoneButton.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/29/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class PhoneButton: UIButton {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    var action: (() -> Void)? = nil
    
    @objc func tapped() {
        action?()
    }

    /// Setups button's layout and adds action to call on specified phone number
    ///
    /// - Parameter phoneNumber: phone number
    func adjustWithPhone(_ phoneNumber: String) {
        icon.image = UIImage(named: "phone_icon")
        title.text = NSLocalizedString("PHONE", comment: "")
        detail.text = phoneNumber
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        
        action = { [weak self] in
            guard let phone_number = self?.detail.text else {return}
            guard let encoded_number = phone_number.addingPercentEncoding(withAllowedCharacters: CharacterSet.decimalDigits) else {return}
            guard let url = URL(string: "telprompt://" + encoded_number) else {return}

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
