//
//  SettingsNibCell.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/1/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

final class SettingsNibCell: UICollectionViewCell {
    static let nibName = "SettingsNibCell"
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var toggle: UISwitch!
    @IBOutlet private var topSeparatorView: UIView!
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    /// hides top separator
    var topSeparatorIsHidden: Bool? {
        didSet {
            topSeparatorView.isHidden = topSeparatorIsHidden!
        }
    }
    
//    var isOn: Bool? {
//        didSet {
//            toggle.isOn = isOn!
//        }
//    }
}
