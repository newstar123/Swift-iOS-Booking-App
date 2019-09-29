//
//  FBPermissionsTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 1/25/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import UIKit

/// The table for selecting Facebook Read Permissions that are used on patron login.
class FBPermissionsTableViewController: SelectionTableViewController {
    
    override class var configs: [(title: String, isSet: Bool)] {
        let allPermissions = FBReadPermission.allCases
        let enabledPermissions = AppConfig.facebookReadPermissions
        return allPermissions.map { ("\($0)", enabledPermissions.contains($0)) }
    }
    
    /// `SelectionTableViewController` related setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = type(of: self).configs.map { $0.title }
        isCellSelectedAt = { row in
            let permissions = type(of: self).configs
            guard permissions.indices.contains(row) else { return false }
            return permissions[row].isSet
        }
        selectionHandler = { row in
            let allPermissions = FBReadPermission.allCases
            guard allPermissions.indices.contains(row) else { return }
            let newPermission = allPermissions[row]
            var permissions = AppConfig.facebookReadPermissions
            if let index = permissions.index(of: newPermission) {
                permissions.remove(at: index)
            } else {
                permissions.append(newPermission)
            }
            AppConfig.facebookReadPermissions = permissions
        }
    }
    
}
