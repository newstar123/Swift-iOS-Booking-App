//
//  JSONExtension.swift
//  Qorum
//
//  Created by Stanislav on 19.02.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import SwiftyJSON

extension JSON {
    
    /// Returns string safely
    ///
    /// - Returns: non null string instance
    func expectingString() throws -> String {
        return try result(expecting: string ?? number?.stringValue)
    }

    /// Returns int safely
    ///
    /// - Returns: non null int instance
    func expectingInt() throws -> Int {
        return try result(expecting: int ?? Int(stringValue))
    }
    
    /// Returns double safely
    ///
    /// - Returns: non null double instance
    func expectingDouble() throws -> Double {
        return try result(expecting: double ?? Double(stringValue))
    }
    
    /// Returns dictionary safely
    ///
    /// - Returns: non null dictionary instance
    func expectingDictionary() throws -> [String: Any] {
        return try result(expecting: dictionaryObject)
    }
    
    /// Returns value safely
    ///
    /// - Returns: non null value instance
    private func result<Value>(expecting value: Value?) throws -> Value {
        guard let value = value else {
            throw error ?? typeMismatch(expected: Value.self, actual: object)
        }
        return value
    }
    
}
