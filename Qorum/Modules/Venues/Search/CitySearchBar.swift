//
//  CitySearchBar.swift
//  Qorum
//
//  Created by Stanislav on 15.11.2017.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import UIKit

class CitySearchBar: LeftAlignedSearchBar {
    
    func setup() {
        placeholder = NSLocalizedString("Search", comment: "")
        backgroundColor = .searchBarBlack
        setImage(UIImage(named: "SearchIcon"),
                 for: .search,
                 state: UIControlState())
        barTintColor = .searchBarBlack
        let searchBarTextField = textField
        searchBarTextField?.textColor = .white
        searchBarTextField?.font = UIFont.opensans.default(15)
        searchBarTextField?.backgroundColor = .searchBarBlack
        searchTextPositionAdjustment = UIOffset(horizontal: 2, vertical: 0)
        setImage(UIImage(), for: .clear, state: UIControlState())
        text = LocationService.shared.selectedVendorCity?.name ?? ""
    }
    
}
