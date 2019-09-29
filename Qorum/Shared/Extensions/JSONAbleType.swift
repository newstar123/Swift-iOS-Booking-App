//
//  JSONAbleType.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONAbleType {
    static func from(json: JSON) throws -> Self
}

extension JSONAbleType {
    
    /// Returns dictionary from JSON response
    ///
    /// - Parameter json: given JSON
    /// - Returns: dictionary instance
    static func result(json: JSON) -> APIResult<Self> {
        do {
            let value = try Self.from(json: json)
            return .value(value)
        } catch {
            return .error(error)
        }
    }
    
    /// Returns array from JSON response
    ///
    /// - Parameter json: given JSON
    /// - Returns: array instance
    /// - Throws: decoding error
    static func arrayFrom(json: JSON) throws -> [Self] {
        guard let jsonArray = json.array else {
            throw json.error ?? typeMismatch(expected: [JSON].self, actual: json.object)
        }
        var array: [Self] = []
        var errors: [Error] = []
        for (index, subJSON) in jsonArray.enumerated() {
            switch Self.result(json: subJSON) {
            case let .value(element):
                array.append(element)
            case let .error(error):
                print("\(Self.self) arrayFrom error at \(index):", error)
                errors.append(error)
            }
        }
        if array.isEmpty, let error = errors.first {
            throw error
        }
        return array
    }
    
    /// Returns result array from JSON response
    ///
    /// - Parameter json: given JSON
    /// - Returns: APIResult instance
    static func arrayResult(from json: JSON) -> APIResult<[Self]> {
        do {
            let array = try arrayFrom(json: json)
            return .value(array)
        } catch {
            return .error(error)
        }
    }
    
}

/// Same as `JSONAbleType` but on decoding failure returns placeholder object
protocol SafeJSONAbleType: JSONAbleType {
    /// A placeholder object returned by the `safelyFrom(json: JSON)` on decoding failure.
    static var placeholder: Self { get }
}

extension SafeJSONAbleType {
    
    /// Decodes given JSON
    ///
    /// - Parameter json: JSON to decode from
    /// - Returns: decoding result or placeholder object
    static func safelyFrom(json: JSON) -> Self {
        do {
            return try from(json: json)
        } catch {
            let placeholder = Self.placeholder
            let log =
            """
            SafeJSONAbleType: failed to decode a \(Self.self) from json:
            \(json)
            Error:
            \(error)
            Returning a placeholder:
            \(placeholder)
            """
            print(log)
            return placeholder
        }
    }
    
}

