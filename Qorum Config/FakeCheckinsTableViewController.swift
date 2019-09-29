//
//  FakeCheckinsTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 11.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for selecting Fake Checkins Mode.
class FakeCheckinsTableViewController: SelectionTableViewController {
    
    /// `SelectionTableViewController` related setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        cells = GenericConfigMode.allCases.map { $0.title }
        selectedRow = { AppConfig.fakeCheckinsMode.row }
        selectionHandler = { AppConfig.fakeCheckinsMode = GenericConfigMode(row: $0) }
    }
    
    /// Also defines `detailTextLabel` text (indicating preferred setting in automatic mode)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.detailTextLabel?.text = {
            switch indexPath.row {
            case 0:
                let automaticFakeCheckinsEnabled = AppConfig.isFakeCheckinsEnabled(for: AppConfig.environment)
                return GenericConfigMode(boolean: automaticFakeCheckinsEnabled).title
            default: return nil
            }
        }()
        return cell
    }
    
}
