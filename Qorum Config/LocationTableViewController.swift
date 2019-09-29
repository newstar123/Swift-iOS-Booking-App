//
//  LocationTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for selecting Qorum location option.
class LocationTableViewController: GenericTableViewController {
    
    /// List of available locations.
    var locations: [CustomLocation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addLocation))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locations = CustomLocation.stored
    }
    
    /// Routes to the Map screen.
    @objc func addLocation() {
        navigationController?.pushViewController(MapViewController(), animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 1 {
            return 1
        }
        let count = locations.count
        guard CustomLocation.currentUntitled?.isAlreadyStored != false else { return count + 1 }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section < 1 {
            cell.textLabel?.text = "Real"
            cell.detailTextLabel?.text = ""
            cell.accessoryType = AppConfig.location.isReal ? .checkmark : .none
            return cell
        }
        let locationIndex = indexPath.row
        guard locations.indices.contains(locationIndex) else {
            cell.textLabel?.text = "    Save Location"
            cell.detailTextLabel?.text = CustomLocation.currentUntitled?.coordinateString
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let location = locations[locationIndex]
        cell.textLabel?.text = location.title.value
        cell.detailTextLabel?.text = location.coordinateString
        cell.accessoryType = location.isCurrent ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section < 1 {
            AppConfig.location = .real
            tableView.reloadData()
            return
        }
        let locationIndex = indexPath.row
        if locations.indices.contains(locationIndex) {
            locations[locationIndex].apply()
            tableView.reloadData()
            return
        }
        guard let location = CustomLocation.currentUntitled else { return }
        let addingAlert = AddingAlert(saving: location) { [weak self] added in
            if added {
                self?.locations = CustomLocation.stored
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        present(addingAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.section > 0, locations.indices.contains(indexPath.row) else { return [] }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove") { [unowned self] (action, indexPath) in
            self.tableView.isEditing = false
            self.locations[indexPath.row].remove()
            self.locations = CustomLocation.stored
        }
        return [deleteAction]
    }
    
}
