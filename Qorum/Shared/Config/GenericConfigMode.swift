//
//  GenericConfigMode.swift
//  Qorum Config
//
//  Created by Stanislav on 11.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

extension IndexPath {
    typealias Row = Int
}

/// Defines the Config Mode for boolean setting.
enum GenericConfigMode: String, CaseIterable {
    
    /// The value is defined outside this struct (like a default value).
    case automatic
    
    /// Defines `true`.
    case enabled
    
    /// Defines `false`.
    case disabled
    
    /// Returns an optional `Bool?` value where `nil` means this is the `automatic` mode.
    var boolean: Bool? {
        switch self {
        case .automatic: return nil
        case .enabled: return true
        case .disabled: return false
        }
    }
    
    /// Defines a row in the `SelectionTableViewController` used in the Qorum Config app.
    var row: IndexPath.Row {
        switch self {
        case .automatic: return 0
        case .enabled: return 1
        case .disabled: return 2
        }
    }
    
    /// Defines a title string for the cell in the `SelectionTableViewController` used in the Qorum Config app.
    var title: String {
        return rawValue.capitalized
    }
    
    /// Makes a mode from given `Bool?`.
    ///
    /// - Parameter boolean: Will make `.automatic` if `nil` is passed.
    init(boolean: Bool?) {
        switch boolean {
        case true?: self = .enabled
        case false?: self = .disabled
        case nil: self = .automatic
        }
    }
    
    /// Makes a mode for given row in the `SelectionTableViewController` used in the Qorum Config app.
    ///
    /// - Parameter row: defines the cell presenting this mode.
    init(row: IndexPath.Row) {
        switch row {
        case 1: self = .enabled
        case 2: self = .disabled
        default: self = .automatic
        }
    }
    
}

