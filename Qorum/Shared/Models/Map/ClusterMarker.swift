//
//  ClusterMarker.swift
//  Qorum
//
//  Created by Stanislav on 05.02.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import UIKit
import GoogleMaps

class ClusterMarker: GMSMarker, GMUClusterItem {
    
    /// marker container view
    let markerContainer = MarkerContainerView(frame: CGRect(x: 0, y: 0, width: 136, height: 70))
    
    /// venues in cluster
    let count: UInt
    
    init(with count: UInt) {
        self.count = count
        super.init()
        self.iconView = markerContainer
        construct()
    }
    
    func construct() {
        markerContainer.nameLabel.text = "\(count)"
        markerContainer.nameLabel.sizeToFit()
        iconView?.frame.size.width = min(markerContainer.nameLabel.frame.width + 60, .deviceWidth - 60)
        markerContainer.nameLabel.textAlignment = .center
        let pinColor = Venue.Status.open(openedOn: .monday, closesAt: Date()).mapMarkerColor
        markerContainer.markerView.shapeLayer.fillColor = pinColor.cgColor
        iconView?.layoutIfNeeded()
    }
    
}


