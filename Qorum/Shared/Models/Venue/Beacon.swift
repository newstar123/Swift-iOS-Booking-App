//
//  Beacon.swift
//  Qorum
//
//  Created by Dima Tsurkan on 12/14/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftyJSON

typealias Meters = Double

struct Beacon {
    
    /// BLE UUID, used to uniquely identify beacon.
    var uuid: UUID
    
    /// Major value, usually Venue ID
    var major: Int?
    
    /// Minor value, usually beacon number
    var minor: Int?
    
    /// Distance to beacon required to activate checkin flow
    var checkinRadius: Meters?
    
    init(uuid: UUID) {
        self.uuid = uuid
    }
    
    init(uuid: UUID, major: Int?, minor: Int?, checkinRadius: Meters?, checkoutRadius: Meters?) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.checkinRadius = checkinRadius
    }
}

// MARK: - JSONAbleType
extension Beacon: JSONAbleType {
    
    static func from(json: JSON) throws -> Beacon {
        let beaconConfigJSON = json["beaconConfig"]
        let beaconAttributesJSON = json["beacon_attributes"]
        let uuidStr = beaconConfigJSON["proximity_uuid"].string ?? ""
        
        var uuid: UUID? = nil
        if let _uuid = UUID(uuidString: uuidStr) {
            uuid = _uuid
        } else {
            return Beacon(uuid: UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")!)
        }
        
        var major: Int?
        var minor: Int?
        var checkinRadius: Meters?
        var checkoutRadius: Meters?
        
        if let _major = beaconConfigJSON["major"].int {
            major = _major
        }
        
        if let _minor = beaconConfigJSON["minor"].int {
            minor = _minor
        }
        
        if let _checkinRadiusStr = beaconAttributesJSON["checkin_radius"].string, let _checkinRadius = Double(_checkinRadiusStr) {
            checkinRadius = _checkinRadius
        }
        
        if let _checkoutRadiusStr = beaconAttributesJSON["checkout_radius"].string, let _checkoutRadius = Double(_checkoutRadiusStr) {
            checkoutRadius = _checkoutRadius
        }
        
        return Beacon(uuid: uuid!,
                      major: major,
                      minor: minor,
                      checkinRadius: checkinRadius,
                      checkoutRadius: checkoutRadius)
    }
    
}
