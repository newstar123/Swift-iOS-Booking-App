//
//  LookupResult.swift
//  Qorum
//
//  Created by Sergiy Kostrykin on 11/1/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON


final class LookupResult {
    
    /// Items array received from AppStore
    var items: [ResultItem] = []
}

struct ResultItem {
    /// App version, received from AppStore
    var version: String?
}

// MARK: - SafeJSONAbleType
extension LookupResult: SafeJSONAbleType {
    
    /// Result placeholder
    static var placeholder: LookupResult {
        return LookupResult()
    }
    
    /// Decodes response from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: Resulting model
    /// - Throws: An error if reading fails, or if the data read is corrupted or otherwise invalid.
    static func from(json: JSON) throws -> LookupResult {
        let result = LookupResult()
        for (_, item_json) : (String, JSON) in json["results"] {
            var item = ResultItem()
            item.version = item_json["version"].string
            result.items.append(item)
        }
        return result
    }
}

extension LookupResult {
    var version: String? {
        return items.first?.version
    }
}
