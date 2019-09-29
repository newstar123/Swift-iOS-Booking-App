//
//  UberType.swift
//  Qorum
//
//  Created by Vadym Riznychok on 5/15/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit

class UberType: NSObject {
    
    /// Uber type title
    let name: String!
    
    /// Price estimates for Uber products
    var estimate: UberTypeEstimate?
    
    /// Data instance representing Uber Product
    var productData: UberProduct?
    
    init(name: String) {
        self.name = name
    }
    
    init(productData: UberProduct) {
        self.name = productData.display_name
        self.productData = productData
    }

}
