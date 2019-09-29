//
//  EnvironmentTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for selecting Qorum environment option.
class EnvironmentTableViewController: SelectionTableViewController {
    
    /// `SelectionTableViewController` setup goes here.
    /// Arranging cells: list of available environments, spacer cell and list of available schemes (https and http).
    override func viewDidLoad() {
        super.viewDidLoad()
        let environmentPaths: [QorumEnvironment.Path] = [.staging, .demoStaging, .demo, .production]
        cells = environmentPaths.map { $0.title }
        cells.append("")
        let environmentSchemes: [QorumEnvironment.Scheme] = [.https, .http]
        cells.append(contentsOf: environmentSchemes.map({ "\($0)".uppercased() }))
        cells.append("") // bottom cell for http description
        isCellSelectedAt = { row in
            let schemeRow = row-1-environmentPaths.count
            if row == environmentPaths.index(of: AppConfig.environment.path) {
                return true // defines selected environment
            } else if schemeRow == environmentSchemes.index(of: AppConfig.environment.scheme) {
                return true // defines selected scheme
            }
            return false
        }
        selectionHandler = { row in
            let schemeRow = row-1-environmentPaths.count
            if environmentPaths.indices.contains(row) {
                // select the environment
                AppConfig.environment.path = environmentPaths[row]
            } else if environmentSchemes.indices.contains(schemeRow) {
                // select the scheme
                AppConfig.environment.scheme = environmentSchemes[schemeRow]
            }
        }
    }
    
    /// Override for specifying cell's `detailTextLabel` text.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. An assertion is raised if you return nil.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.detailTextLabel?.text = {
            switch indexPath.row {
            case cells.count-4: return "need re-launch" // spacer cell - describing environment selection behavior
            case cells.count-1: return "http is for sniffer debugging" // bottom cell
            default: return nil
            }
        }()
        return cell
    }
    
}
