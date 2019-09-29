//
//  AdvancedTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 10.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for accessing Advanced Qorum options
class AdvancedTableViewController: GenericTableViewController {
    
    /// List of titles for advanced settings
    let cells = ["Fake Checkins Mode",
                 "Stripe Sandbox Mode",
                 "Bill screen Ad placeholder",
                 "Facebook Permissions",
                 "Max distance to checkin"]
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = cells[indexPath.row]
        cell.detailTextLabel?.text = {
            switch indexPath.row {
            case 0: return AppConfig.fakeCheckinsMode.title
            case 1: return AppConfig.stripeSandboxMode.title
            case 2: return AppConfig.billAdPlaceholder.title
            case 3: return FBPermissionsTableViewController.stateDescription
            case 4: return "\(AppConfig.maxDistanceToCheckin.description) meters"
            default: return nil
            }
        }()
        cell.accessoryType = {
            switch indexPath.row {
            case 0, 1, 2, 3, 4:
                return .disclosureIndicator
            default:
                return .none
            }
        }()
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let fakeCheckinsTVC = FakeCheckinsTableViewController()
            fakeCheckinsTVC.title = cells[indexPath.row]
            navigationController?.pushViewController(fakeCheckinsTVC, animated: true)
        case 1:
            let stripeSandboxTVC = StripeSandboxTableViewController()
            stripeSandboxTVC.title = cells[indexPath.row]
            navigationController?.pushViewController(stripeSandboxTVC, animated: true)
        case 2:
            let billAdTVC = BillAdTableViewController()
            billAdTVC.title = cells[indexPath.row]
            navigationController?.pushViewController(billAdTVC, animated: true)
        case 3:
            let fbPermissionsTVC = FBPermissionsTableViewController()
            fbPermissionsTVC.title = cells[indexPath.row]
            navigationController?.pushViewController(fbPermissionsTVC, animated: true)
        case 4:
            let alert = UIAlertController(title: "\(cells[indexPath.row]) (in meters)",
                                          message: "Recommended distance is 250 meters",
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.keyboardType = .decimalPad
                textField.enablesReturnKeyAutomatically = true
                textField.text = AppConfig.maxDistanceToCheckin.description
            }
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                if  let text = alert.textFields?.first?.text,
                    let maxDistance = Double(text)
                {
                    AppConfig.maxDistanceToCheckin = maxDistance
                }
                tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
}
