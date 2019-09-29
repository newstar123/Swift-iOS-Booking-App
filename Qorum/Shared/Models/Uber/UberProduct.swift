//
//  UberProduct.swift
//  Qorum
//
//  Created by Vadym Riznychok on 2/16/17.
//  Copyright © 2017 Qorum. All rights reserved.
//

import UIKit
import SwiftyJSON

final class UberProduct {
    
    // MARK: - Properties
    
    /// Unique identifier representing a specific product for a given latitude & longitude.
    let product_id: String // Required
    
    /// Image URL representing the product.
    var imageUrl: String?
    
    /// Display name of product. Ex: "UberBLACK".
    var display_name: String
    
    /// Capacity of product. Ex: 4, for a product that fits 4.
    var capacity: Int?
    
    /// Description of product. Ex: "The original Uber".
    var name_description: String?
    
    // MARK: - Init/Deinit
    init(product_id: String, display_name: String) {
        self.product_id = product_id
        self.display_name = display_name
    }
    
}

// MARK: - CustomStringConvertible
extension UberProduct: CustomStringConvertible {
    
    var description: String {
        return "display_name: \(String(describing: display_name)) image_URL: \(String(describing: imageUrl))"
    }
    
}

//Copiyng
extension UberProduct {
    
    func copy() -> UberProduct {
        let result = UberProduct(product_id: product_id, display_name: display_name)
        result.imageUrl = imageUrl
        result.capacity = capacity
        result.name_description = name_description
        return result
    }
    
}

// MARK: - SafeJSONAbleType
extension UberProduct: SafeJSONAbleType {
    
    static var placeholder: UberProduct {
        return UberProduct(product_id: "", display_name: "")
    }
    
    static func from(json: JSON) throws -> UberProduct {
        let product_id = try json["product_id"].expectingString()
        let display_name = json["display_name"].string ?? ""
        
        let prod = UberProduct(product_id: product_id, display_name: display_name)
        prod.imageUrl = json["image"].string
        prod.capacity = json["capacity"].int
        prod.name_description = json["description"].string
        return prod
    }
    
}
