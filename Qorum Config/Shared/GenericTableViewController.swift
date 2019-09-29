//
//  GenericTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 11.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The `UITableViewController` subclass designed for convenience.
class GenericTableViewController: UITableViewController {
    
    /// Generic reuse identifier for cells.
    let cellReuseIdentifier = "cellId"
    
    /// Called after the controller's view is loaded into memory.
    /// Registers `GenericTableViewCell` for `cellReuseIdentifier`.
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GenericTableViewCell", bundle: nil),
                           forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    /// Reloads the data for the table view when called.
    ///
    /// - Parameter animated: If true, the view was added to the window using an animation.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    /// Convenience `Bool` toggling method.
    /// Toggles given variable and reloads the table view.
    /// Useful for switching boolean `AppConfig`'s properties like `beaconsEnabled`.
    /// Widely used in the `tableView(_:didSelectRowAt:)` method.
    ///
    /// - Parameter boolean: The `Bool` variable to toggle.
    func toggle(_ boolean: inout Bool) {
        boolean = !boolean
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// Dequeues the cell with `cellReuseIdentifier` for given index path.
    ///
    /// So you don't need to dequeue it in the subclasses - just call
    ///
    ///     let cell = super.tableView(tableView, cellForRowAt: indexPath).
    ///
    /// - Parameters:
    ///   - tableView: A table-view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: A `GenericTableViewCell` object for the specified row. An assertion is raised if you return nil.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    }
    
}
