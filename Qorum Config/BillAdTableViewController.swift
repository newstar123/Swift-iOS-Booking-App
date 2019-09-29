//
//  BillAdTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 12.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for configuring advert in the Bill scene.
class BillAdTableViewController: SelectionTableViewController {
    
    /// `SelectionTableViewController` related setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = BillAdPlaceholder.allCases.map { $0.title }
        cells.append(contentsOf: ["", "Fetch image from server"])
        isCellSelectedAt = { row in
            switch row {
            case 0, 1:
                return AppConfig.billAdPlaceholder.rawValue == row
            case 3:
                return AppConfig.billAdFetchEnabled
            default:
                return false
            }
        }
        selectionHandler = { [weak self] row in
            switch row {
            case 0, 1:
                if let placeholder = BillAdPlaceholder(rawValue: row) {
                    AppConfig.billAdPlaceholder = placeholder
                }
            case 3:
                self?.toggle(&AppConfig.billAdFetchEnabled)
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.detailTextLabel?.text = {
            switch indexPath.row {
            case 2: return "Enable next setting to override placeholder"
            default: return nil
            }
        }()
        return cell
    }
    
}
