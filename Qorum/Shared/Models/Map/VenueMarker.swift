//
//  VenueMarker.swift
//  Qorum
//
//  Created by Dima Tsurkan on 11/10/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class VenueMapItem: NSObject, GMUClusterItem {
    
    /// map marker coordinates
    var position: CLLocationCoordinate2D
    
    /// venue assosiated with marker
    var venue: Venue
    
    init(position: CLLocationCoordinate2D, venue: Venue) {
        self.position = position
        self.venue = venue
    }
    
}

class VenueMarker: GMSMarker, GMUClusterItem {
    
    /// venue assosiated with marker
    let venue: Venue
    
    /// marker container view
    let markerContainer = MarkerContainerView(frame: CGRect(x: 0, y: 0, width: 136, height: 94))
    
    /// is marker expanded
    var isExpanded: Bool {
        return markerContainer.markerView.bodyHeight > markerContainer.markerBodyHeight
    }
    
    init(with venue: Venue, preferAddresses: Bool) {
        self.venue = venue
        super.init()
        iconView = markerContainer
        tracksViewChanges = false
        construct(preferAddresses: preferAddresses)
    }
    
    /// Returns VenueMarker
    ///
    /// - Parameter preferAddresses: Defines marker color and text content
    func construct(preferAddresses: Bool) {
        groundAnchor = markerContainer.groundAnchor
        var title = venue.name
        if preferAddresses {
            if let address = venue.address {
                title = address
            }
            
            if  let zip = venue.zip,
                let city = venue.city,
                let state = venue.state,
                zip.isNotEmpty,
                title.isNotEmpty
            {
                title = "\(title), \(city), \(state) \(zip)"
            }
            title = title.isNotEmpty ? title : venue.name
        }
        
        markerContainer.nameLabel.text = title
        
        markerContainer.nameLabel.sizeToFit()
        // iconView.width = nameLabel.width + 30  DT_MARK
        iconView?.frame.size.width = min(markerContainer.nameLabel.frame.width + 66, .deviceWidth - 60)
        markerContainer.nameLabel.textAlignment = .center
        let status = venue.status()
        let pinColor = preferAddresses ? .venueColor(venue.venue_type ?? "") : status.mapMarkerColor
        markerContainer.markerView.shapeLayer.fillColor = pinColor.cgColor
        iconView?.layoutIfNeeded()
    }
    
    /// Updates marker state - shrinks or expands
    func expand() {
        let newBodyHeight: CGFloat
        let newNumberOfLines: Int
        if isExpanded {
            newBodyHeight = markerContainer.markerBodyHeight
            newNumberOfLines = 1
        } else {
            guard markerContainer.nameLabel.isTextTruncated else { return }
            newBodyHeight = markerContainer.markerBodyExpandedHeight
            newNumberOfLines = 2
        }
        
        fadeNameLabel(for: 0.4) { [weak markerContainer] duration in
            guard let markerContainer = markerContainer else { return }
            markerContainer.nameLabel.numberOfLines = newNumberOfLines
            let previousMarkerPath = markerContainer.markerView.shapeLayer.path
            markerContainer.markerView.bodyHeight = newBodyHeight
            let newMarkerPath = markerContainer.markerView.mainPath.cgPath
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = previousMarkerPath
            animation.toValue = newMarkerPath
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
            animation.fillMode = kCAFillModeBackwards
            markerContainer.markerView.shapeLayer.add(animation, forKey: nil)
            markerContainer.markerView.shapeLayer.path = newMarkerPath
        }
    }
    
    /// Shrinks map marker
    func shrink() {
        if isExpanded {
            expand()
        }
    }
    
    /// Animates marker with fade animation
    ///
    /// - Parameters:
    ///   - duration: animation duration
    ///   - animations: animation block
    private func fadeNameLabel(for duration: TimeInterval,
                               animations: @escaping (TimeInterval) -> ()) {
        let fadeDuration = duration/4
        UIView.animate(withDuration: fadeDuration, animations: {
            self.markerContainer.nameLabel.alpha = 0
        }) { _ in
            let interDuration = duration/2
            animations(interDuration)
            delayToMainThread(interDuration) {
                UIView.animate(withDuration: fadeDuration) {
                    self.markerContainer.nameLabel.alpha = 1
                }
            }
        }
    }
    
}

