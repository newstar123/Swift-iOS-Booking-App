//
//  SwiftExtentions.swift
//  Qorum
//
//  Created by Dima Tsurkan on 9/25/17.
//  Copyright © 2017 Bizico. All rights reserved.
//

import Foundation

extension Optional {
    
    /// Whether the optional is not `nil`
    var hasValue: Bool {
        switch self {
        case .none:
            return false
        case .some(_):
            return true
        }
    }
    
}

// Anything that can hold a value (strings, arrays, etc)
protocol Occupiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

// Give a default implementation of isNotEmpty, so conformance only requires one implementation
extension Occupiable {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension String: Occupiable { }

// I can't think of a way to combine these collection types. Suggestions welcome.
extension Array: Occupiable { }
extension Dictionary: Occupiable { }
extension Set: Occupiable { }

// Extend the idea of occupiability to optionals. Specifically, optionals wrapping occupiable things.
extension Optional where Wrapped: Occupiable {
    
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }
    
    /// Whether the occupiable optional is not 'nil' and it's not empty as well
    var isNotNilNorEmpty: Bool {
        return !isNilOrEmpty
    }
    
}

// Extend Array
extension Array {
    
    mutating func g_moveToFirst(_ index: Int) {
        guard index != 0 && index < count else { return }
        
        let item = self[index]
        remove(at: index)
        insert(item, at: 0)
    }
}

// MARK: - [AnyObject]
extension Collection where Element: AnyObject {
    
    /// Looks for object that matches specified type
    ///
    /// - Parameters:
    ///   - type: The Element subclass to look for
    ///   - predicate: Optional predicate closure for more detailed filter
    /// - Returns: The first object matching specified type and predicate
    func find<T: AnyObject>(_ type: T.Type,
                            where predicate: ((T) -> Bool)? = nil) -> T? {
        let found = first { (obj) -> Bool in
            if let t = obj as? T {
                return predicate?(t) ?? true
            }
            return false
        }
        return found as? T
    }
    
}

