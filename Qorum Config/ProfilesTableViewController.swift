//
//  ProfilesTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 11.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The table for managing configuration profiles
class ProfilesTableViewController: GenericTableViewController {
    
    /// List of available profiles
    fileprivate var profiles: [ConfigProfile] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    /// Returns a list of profiles including stored profiles and the default one
    fileprivate static var getProfiles: [ConfigProfile] {
        return [ConfigProfile.defaultProfile] + ConfigProfile.stored
    }
    
    /// `GenericTableViewController` related setup.
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sharing",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(openSharing))
        profiles = ProfilesTableViewController.getProfiles
    }
    
    /// Route to the Profile Sharing scene
    @objc func openSharing() {
        let sharingVC = ProfileSharingViewController()
        sharingVC.title = "Profile Sharing"
        navigationController?.pushViewController(sharingVC, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfigProfile.currentUntitled!.isAlreadyStored ? profiles.count : profiles.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard profiles.indices.contains(indexPath.row) else {
            cell.textLabel?.text = "    Save Profile"
            cell.detailTextLabel?.text = StorableTitle.untitled.value
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let profile = profiles[indexPath.row]
        cell.textLabel?.text = profile.title.value
        cell.detailTextLabel?.text = ""
        cell.accessoryType = profile.isCurrent ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if profiles.indices.contains(indexPath.row) {
            profiles[indexPath.row].apply()
            tableView.reloadData()
            return
        }
        let addingAlert = AddingAlert(saving: ConfigProfile.currentUntitled!) { [weak self] added in
            if added {
                self?.profiles = ProfilesTableViewController.getProfiles
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        present(addingAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard profiles.indices.contains(indexPath.row) && indexPath.row != 0 else { return [] }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove") { [unowned self] (action, indexPath) in
            self.tableView.isEditing = false
            self.profiles[indexPath.row].remove()
            self.profiles = ProfilesTableViewController.getProfiles
        }
        return [deleteAction]
    }
    
}
