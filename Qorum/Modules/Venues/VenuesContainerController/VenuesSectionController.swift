//
//  VenuesSectionController.swift
//  Qorum
//
//  Created by Vadym Riznychok on 10/9/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import IGListKit

class VenuesSectionController: ListSectionController {

    let index: Int
    var cellSize: CGSize
    var venueHolder: VenueHolder = VenueHolder(venues: [])
    
    deinit { }
    
    init(containerSize: CGSize, index: Int) {
        self.cellSize = CGSize(width: containerSize.width, height: (containerSize.height - 101)/3)
        self.index = index
    }
    
    override func numberOfItems() -> Int {
        return venueHolder.venues.count
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return cellSize
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: VenuesCollectionCell
        cell = collectionContext!.dequeueReusableCell(withNibName: "VenuesCollectionCell", bundle: nil, for: self, at: index) as! VenuesCollectionCell
        if index < venueHolder.venues.count {
            cell.onVenueViewTabInteraction = { [weak self] in
                guard let welf = self else { return }
                let controller = welf.viewController as! VenuesContainerController
                controller.delegate?.viewTab(for: welf.venueHolder.venues[index], by: cell, controllerId: welf.index)
            }
            cell.onVenueOpenTabInteraction = { [weak self] in
                guard let welf = self else { return }
                let controller = welf.viewController as! VenuesContainerController
                controller.delegate?.openTab(for: welf.venueHolder.venues[index], by: cell, controllerId: welf.index)
            }
            cell.onVenueDetailsInteraction = { [weak self] in
                guard let welf = self else { return }
                let controller = welf.viewController as! VenuesContainerController
                controller.delegate?.showDetails(for: welf.venueHolder.venues[index], by: cell, controllerId: welf.index)
            }
            let venue = venueHolder.venues[index]
            cell.fillWith(venue: venue)
            let mayOpenTab = venueHolder.mayOpenTab(in: venue)
            cell.updateTabActivityType(with: venue, mayOpenTab: mayOpenTab)
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        if let holder = object as? VenueHolder {
            venueHolder = holder
        }
    }
}
