//
//  SelectionTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 31.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The `GenericTableViewController` subclass designed
/// for setting up the table which has cells with checkmarks to toggle.
class SelectionTableViewController: GenericTableViewController {
    
    /// The list of configs in this table where `title` is readable string and `isSet` is corresponding setting state.
    /// This feature is optional and can be useful for defining the `stateDescription`.
    class var configs: [(title: String, isSet: Bool)] {
        return []
    }
    
    /// Represents a list of selected cells in this table.
    /// Defined by `configs` override.
    class var stateDescription: String {
        var description = ""
        for (config, isSet) in configs {
            if isSet {
                if !description.isEmpty {
                    description.append(", ")
                }
                description.append(config)
            }
        }
        if description.count > 26 {
            if configs.contains(where: { $0.1 == false }) {
                description = "Multiple"
            } else {
                description = "All enabled"
            }
        }
        return description
    }
    
    /// Contains titles for cells with checkmarks.
    var cells: [String] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    /// Defines `IndexPath.Row` of the selected cell
    var selectedRow: (() -> IndexPath.Row)? = nil
    
    /// Whether the cell at given `IndexPath.Row` is selected one.
    lazy var isCellSelectedAt: ((IndexPath.Row) -> Bool) = { [weak self] row in
        row == self?.selectedRow?()
    }
    
    /// Called when the cell at given `IndexPath.Row` gets selected - i.e on `tableView(_:didSelectRowAt:)` execution.
    var selectionHandler: ((IndexPath.Row) -> ())? = nil
    
    // MARK: - Table view data source
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section in tableView.
    /// - Returns: The `cells` count.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// Returns a cell with title of `cells` coresponding element
    /// and with accessory type of `checkmark`, if `isCellSelectedAt` is `true` for this row.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: A `GenericTableViewCell` object for the specified row. An assertion is raised if you return nil.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = cells[indexPath.row]
        let isSelectedCell = isCellSelectedAt(indexPath.row)
        cell.accessoryType = isSelectedCell ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    /// Tells the delegate that the specified row is now selected.
    /// Calls the `selectionHandler` for given index path row.
    ///
    /// - Parameters:
    ///   - tableView: A table-view object informing the delegate about the new row selection.
    ///   - indexPath: An index path locating the new selected row in tableView.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionHandler?(indexPath.row)
        tableView.reloadData()
    }
    
}
