//
//  DeveloperModeTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 19.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for selecting Qorum Developer Mode options
class DeveloperModeTableViewController: SelectionTableViewController {
    
    override class var configs: [(title: String, isSet: Bool)] {
        return [("Error Alerts", AppConfig.developerModeEnabled),
                ("POS info", AppConfig.displayPOSInfo),
                ("Quick launch", AppConfig.quickLaunch),
                ("Open Venues", AppConfig.allVenuesAlwaysOpen)]
    }
    
    /// `SelectionTableViewController` related setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = type(of: self).configs.map { $0.title }
        isCellSelectedAt = { row in
            let configs = type(of: self).configs
            guard configs.indices.contains(row) else { return false }
            return configs[row].isSet
        }
        selectionHandler = { [weak self] row in
            switch row {
            case 0: self?.toggle(&AppConfig.developerModeEnabled)
            case 1:  self?.toggle(&AppConfig.displayPOSInfo)
            case 2:  self?.toggle(&AppConfig.quickLaunch)
            case 3:  self?.toggle(&AppConfig.allVenuesAlwaysOpen)
            default: break
            }
        }
    }
    
    /// Also defines `detailTextLabel` text, which represents explanation of corresponding setting.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.detailTextLabel?.text = {
            switch indexPath.row {
            case 0: return "Shows info on server error"
            case 1: return "Shows POS type for Venue"
            case 2: return "Instant UI access on launch"
            case 3: return "All the venues are always open"
            default: return nil
            }
        }()
        return cell
    }
    
}
