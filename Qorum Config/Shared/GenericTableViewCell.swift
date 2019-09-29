//
//  GenericTableViewCell.swift
//  Qorum Config
//
//  Created by Stanislav on 11.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The `UITableViewCell` subclass designed for use in `GenericTableViewController` and its subclasses.
class GenericTableViewCell: UITableViewCell {
    
    /// The cell setup.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        detailTextLabel?.text = ""
    }
    
}
