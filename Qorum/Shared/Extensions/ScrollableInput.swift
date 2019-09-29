//
//  ScrollableInput.swift
//  Qorum
//
//  Created by Stanislav on 11.12.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

@objc protocol ScrollableInput: NSObjectProtocol {
    @objc func inputChanged(_ notification: Notification)
}

extension ScrollableInput {
    
    /// Adds observer for keyboard changing frame events
    func addKeyboardObserver() {
        Notification.Name.UIKeyboardWillChangeFrame
            .add(observer: self, selector: #selector(inputChanged(_:)))
    }

    /// Removes observer for keyboard changing frame events
    func removeKeyboardObserver() {
        Notification.Name.UIKeyboardWillChangeFrame.remove(observer: self)
    }
    
    /// Updates scroll view to avoid getting covered by the keyboard
    ///
    /// - Parameters:
    ///   - scrollView: scroll view to update
    ///   - userInfo: dictionary with keyboard frame data
    /// - Returns: insets to change
    @discardableResult
    func update(scrollView: UIScrollView, with userInfo: [AnyHashable: Any]?) -> CGFloat? {
        guard
            let userInfo = userInfo,
            let frameValue = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        let rawBottomInset = (.deviceHeight - frameValue.origin.y) - (scrollView.superview!.height - scrollView.y - scrollView.height)
        let bottomInset = max(0, rawBottomInset)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            UIView.animate(withDuration: duration.doubleValue, delay: 0, options: .beginFromCurrentState, animations: {
                if let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                    UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.intValue)!)
                }
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
            }, completion: nil)
        } else {
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
        }
        return bottomInset
    }
    
}

