//
//  GenderPicker.swift
//  Qorum
//
//  Created by Stanislav on 01.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

class GenderPicker: UIPickerView {
    
    weak var textField: UITextField? {
        didSet {
            oldValue?.inputView = nil
            textField?.inputView = self
            dataSource = self
            delegate = self
        }
    }
    
    func select(gender: User.Gender, animated: Bool = false) {
        let row: Int
        switch gender {
        case .male: row = 0
        case .female: row = 1
        case .unspecified: row = 0
        }
        selectRow(row, inComponent: 0, animated: animated)
    }
    
    func title(for row: Int) -> String {
        let gender: User.Gender
        switch row {
        case 0: gender = .male
        case 1: gender = .female
        default: gender = .unspecified
        }
        return gender.readableLocalized
    }
    
}

// MARK: - UIPickerViewDataSource
extension GenderPicker: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
}

// MARK: - UIPickerViewDelegate
extension GenderPicker: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return title(for: row)
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        textField?.text = title(for: row)
    }
    
}


