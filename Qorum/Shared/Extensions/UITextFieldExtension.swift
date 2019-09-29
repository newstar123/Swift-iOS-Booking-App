//
//  UITextFieldExtension.swift
//  Qorum
//
//  Created by Stanislav on 31.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

extension UITextField {
    
    /// returns true if textField's text is empty
    var isTextEmptyOrNil: Bool {
        return text?.isEmpty ?? true
    }
    
    /// Adds clear button to the textField
    ///
    /// - Parameter image: clear button image
    func setClearButton(with image: UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .whileEditing
    }
    
    /// Blocks field to prevent editing
    ///
    /// - Parameter image: right view image
    func setImmutabilityIndicator(with image: UIImage) {
        let view = UIImageView()
        view.image = image
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        view.contentMode = .scaleAspectFit
        rightView = view
        rightViewMode = .always
    }
    
    /// Clears textField and hides rightView
    @objc func clear() {
        text = ""
        rightView?.isHidden = true
    }
    
    /// Adds toolbar above keyboard view
    ///
    /// - Parameter frame: toolbar frame
    /// - Returns: toolbar instance
    @discardableResult
    func applyToolbar(frame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)) -> UIToolbar {
        let toolBar = UIToolbar(frame: frame)
        toolBar.barStyle = .blackTranslucent
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let placeholderItem =  UIBarButtonItem(title: placeholder ?? "",
                                               style: .plain,
                                               target: nil,
                                               action: nil)
        placeholderItem.tintColor = UIColor(white: 1, alpha: 0.7)
        let title: String
        switch returnKeyType {
        case .done: title = "Done"
        case .next: title = "Next"
        default: title = "Return"
        }
        let doneItem = UIBarButtonItem(title: NSLocalizedString(title, comment: ""),
                                       style: .done,
                                       target: self,
                                       action: #selector(resignFirstResponder))
        let leftItem = UIBarButtonItem(title: NSLocalizedString(title, comment: ""),
                                       style: .done,
                                       target: nil,
                                       action: nil)
        leftItem.tintColor = .clear
        toolBar.items = [leftItem, spaceItem, placeholderItem, spaceItem, doneItem]
        inputAccessoryView = toolBar
        return toolBar
    }
    
}

