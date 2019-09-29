//
//  SettingsTableViewCell.swift
//  Qorum
//
//  Created by Stanislav on 29.11.2017.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit

protocol SettingsTableViewCellDelegate: class {
    func settingsTableViewCell(_ cell: SettingsTableViewCell, at row: Int, didSet isOn: Bool)
}

class SettingsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var settingDetails: UILabel!
    
    var row = 0
    
    weak var delegate: SettingsTableViewCellDelegate?
    
    // MARK: - Actions
    
    @IBAction func settingSwitchDidSet(_ sender: Any) {
        let isOn = (sender as! UISwitch).isOn
        delegate?.settingsTableViewCell(self, at: row, didSet: isOn)
    }
    
}
