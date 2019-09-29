//
//  BirthdayPicker.swift
//  Qorum
//
//  Created by Stanislav on 01.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class BirthdayPicker: UIDatePicker {
    
    var formatter = Date.birthdayFormatter
    
    weak var textField: UITextField? {
        didSet {
            oldValue?.inputView = nil
            textField?.inputView = self
        }
    }
    
    @objc func birthdayValueChanged() {
        textField?.text = formatter.string(from: date)
    }
    
}


