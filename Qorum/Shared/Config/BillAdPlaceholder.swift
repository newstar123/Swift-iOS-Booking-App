//
//  BillAdPlaceholder.swift
//  Qorum
//
//  Created by Stanislav on 12.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit

/// Defines an option to use predefined advert image asset as a placeholder in the `Bill` screen.
enum BillAdPlaceholder: IndexPath.Row, CaseIterable {
    case absolutElyx, budweiser
    
    /// Predefined advert `UIImage` asset.
    var image: UIImage {
        switch self {
        case .absolutElyx:
            return #imageLiteral(resourceName: "Absolut-Elyx")
        case .budweiser:
            return #imageLiteral(resourceName: "Budweiser_ad")
        }
    }
    
    /// Predefined advert name.
    var title: String {
        switch self {
        case .absolutElyx:
            return "Absolut Elyx"
        case .budweiser:
            return "Budweiser"
        }
    }
    
}

// MARK: - Codable
extension BillAdPlaceholder: Codable {
    
}
