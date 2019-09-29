//
//  MarketRadius.swift
//  Qorum
//
//  Created by Sergiy Kostrykin on 2/8/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

final class MarketRadius {
    
    /// Minimal available distance to the market/city to use the app.
    let radius: Double
    
    init(radius: Double)
    {
        self.radius = radius
    }
}

extension MarketRadius: JSONAbleType {
    
    static func from(json: JSON) throws -> MarketRadius {
        let radius = try json["result"].expectingDouble()
        return MarketRadius(radius: radius)
    }
}
