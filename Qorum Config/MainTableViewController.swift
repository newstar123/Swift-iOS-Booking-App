//
//  MainTableViewController.swift
//  Qorum Config
//
//  Created by Stanislav on 30.08.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// The main Configurator's controller that represents the list of all available configuration settings
class MainTableViewController: GenericTableViewController {
    
    /// Enum that represents the list of all available configuration settings and their properties
    fileprivate enum ConfiguratorSettings: Int, CaseIterable {
        case
        Profile,
        Environment,
        Location,
        Developer_Mode,
        Track_Beacons,
        Uber_Sandbox_Mode,
        Track_Events_for_Analytics,
        Advanced,
        Reset_Config
        
        /// Title for the setting
        var title: String {
            return "\(self)".replacingOccurrences(of: "_", with: " ")
        }
        
        /// Description of the setting
        var description: String? {
            switch self {
            case .Profile:
                return (ConfigProfile.currentStored?.title ?? .untitled).value
            case .Environment:
                return AppConfig.environment.path.title
            case .Location:
                if AppConfig.location.isReal {
                    return "Real"
                }
                if let title = CustomLocation.currentStored?.title.value {
                    return title
                }
                return CustomLocation.currentUntitled?.coordinateString ?? "Custom"
            case .Developer_Mode:
                return DeveloperModeTableViewController.stateDescription
            case .Track_Beacons:
                return "disable to save battery"
            case .Track_Events_for_Analytics:
                return "need re-login"
            default:
                return nil
            }
        }
        
        /// Accessory type for the TableViewCell related to the setting
        var accessoryType: UITableViewCell.AccessoryType {
            switch self {
            case .Track_Beacons where AppConfig.beaconsEnabled:
                return .checkmark
            case .Uber_Sandbox_Mode where AppConfig.uberSandboxModeEnabled:
                return .checkmark
            case .Track_Events_for_Analytics where AppConfig.eventsTrackingEnabled:
                return .checkmark
            default:
                return associatedController == nil ? .none : .disclosureIndicator
            }
        }
        
        /// Associated ViewController for the setting
        var associatedController: UIViewController? {
            let vc: UIViewController?
            switch self {
            case .Profile:
                vc = ProfilesTableViewController()
                vc?.title = "Profiles"
                return vc
            case .Environment:
                vc = EnvironmentTableViewController()
            case .Location:
                vc = LocationTableViewController()
            case .Developer_Mode:
                vc = DeveloperModeTableViewController()
            case .Advanced:
                vc = AdvancedTableViewController()
            default:
                return nil
            }
            vc?.title = self.title
            return vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Qorum Config"
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConfiguratorSettings.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let setting = ConfiguratorSettings(rawValue: indexPath.row) {
            cell.textLabel?.text = setting.title
            cell.detailTextLabel?.text = setting.description
            cell.accessoryType = setting.accessoryType
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = ConfiguratorSettings(rawValue: indexPath.row) else { return }
        if let associatedController = setting.associatedController {
            navigationController?.pushViewController(associatedController, animated: true)
            return
        }
        switch setting {
        case .Track_Beacons:
            toggle(&AppConfig.beaconsEnabled)
        case .Uber_Sandbox_Mode:
            toggle(&AppConfig.uberSandboxModeEnabled)
        case .Track_Events_for_Analytics:
            toggle(&AppConfig.eventsTrackingEnabled)
        case .Reset_Config:
            let confirmAlert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
            confirmAlert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                tableView.deselectRow(at: indexPath, animated: true)
            }))
            confirmAlert.addAction(.init(title: setting.title, style: .destructive, handler: { _ in
                AppConfig.reset()
                ConfigProfile.reset()
                CustomLocation.reset()
                tableView.reloadData()
            }))
            present(confirmAlert, animated: true, completion: nil)
        default:
            break
        }
    }
    
}
