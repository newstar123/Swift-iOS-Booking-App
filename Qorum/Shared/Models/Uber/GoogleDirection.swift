//
//  GoogleDirection.swift
//  Qorum
//
//  Created by Vadym Riznychok on 12/5/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMaps

final class GoogleDirection: JSONAbleType {
    
    /// Routes planning status
    var status: String!
    
    /// Possible routes suggestions
    var routes: [AnyObject]!
    
    
    /// Parses data from response
    ///
    /// - Parameter json: incoming JSON
    /// - Returns: GoogleDirection model
    /// - Throws: An error if reading fails, or if the data read is corrupted or otherwise invalid.
    static func from(json: JSON) throws -> GoogleDirection {
        let direction = GoogleDirection()
        
        if let status = json["status"].string {
            direction.status = status
        }
        
        if let routes = json["routes"].arrayObject as [AnyObject]? {
            direction.routes = routes
        }
        
        return direction
    }
    
    /// Creates GMSPath instance to present on map
    ///
    /// - Returns: path to present
    func path() -> GMSPath? {
        if routes.count > 0 {
            let route = self.routes.last as! [String: AnyObject]
            let polyline = route["overview_polyline"] as! [String: AnyObject]
            return GMSPath(fromEncodedPath: polyline["points"] as! String)
        }
        
        return nil
    }
    
    /// Creates dictionary from self
    ///
    /// - Returns: Dictionary instance
    func route() -> [String: AnyObject]? {
        guard status == "OK", routes.count > 0 else { return nil }
        
        let route = self.routes.last as! [String: AnyObject]
        let legs = route["legs"] as! [[String: AnyObject]]
        return legs.first
    }
    
}
