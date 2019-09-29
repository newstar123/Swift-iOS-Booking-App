//
//  Feature.swift
//  Qorum
//
//  Created by Vadym Riznychok on 11/16/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

class Feature: NSObject {
    
    /// Feature title
    private(set) var name = ""
    private(set) var data: String?
    
    /// Parses string with Feature objects and returns Feature instance
    ///
    /// - Parameter string: string to parse
    /// - Returns: Feature
    static func from(string: String?) -> Feature? {
        guard let string = string else { return nil }
        let feature = Feature()
        let items = string.components(separatedBy: "=")
        if items.count > 1 {
            feature.name = items[0]
            feature.data = items[1]
        } else {
            feature.name = string
        }
        return feature
    }
    
}
