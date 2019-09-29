//
//  DefaultsStorable.swift
//  Qorum Config
//
//  Created by Stanislav on 1/25/19.
//  Copyright © 2019 Bizico. All rights reserved.
//

import UIKit

extension String {
    
    /// Returns true if the string is acceptable `StorableTitle` value to store a `UserDefaultsStorable` entity with.
    var isTitleOk: Bool {
        if isEmpty { return false }
        if self == StorableTitle.untitled.value { return false }
        if self == StorableTitle.default.value { return false }
        return true
    }
    
}

/// The title container for storing `UserDefaultsStorable` entities.
struct StorableTitle {
    
    /// Contained `String` value.
    /// Used as a key in the `UserDefaults` and as name/title for `UserDefaultsStorable` entity.
    let value: String
    
    /// Defines a title for `UserDefaultsStorable` entity which has no title yet.
    static let untitled = StorableTitle(value: "Untitled")
    
    /// Defines a title for default `UserDefaultsStorable` entity.
    static let `default` = StorableTitle(value: " Default")
    
    /// Returns true if the title is acceptable to store an entity with.
    var isOk: Bool {
        return value.isTitleOk
    }
    
}

// MARK: - Equatable
extension StorableTitle: Equatable {
    
    /// Ignore title inequality for UserDefaultsStorable types.
    static func == (lhs: StorableTitle, rhs: StorableTitle) -> Bool {
        return true
    }
    
}

// MARK: - ExpressibleByStringLiteral
extension StorableTitle: ExpressibleByStringLiteral {
    
    /// String literal initializer for convenience.
    ///
    /// - Parameter stringLiteral: The string literal which defines the `value`.
    init(stringLiteral: StringLiteralType) {
        value = stringLiteral
    }
    
}

// MARK: - Codable
extension StorableTitle: Codable {
    
    /// The `Codable` Keys descriptor for `StorableTitle`.
    ///
    /// - value: A key for the `value` variable.
    enum CodingKeys: CodingKey {
        case value
    }
    
    /// Creates a new instance by decoding from the given decoder.
    /// Supports decoding from single contained `String` value and from keyed contained.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    public init(from decoder: Decoder) throws {
        if  let container = try? decoder.container(keyedBy: CodingKeys.self),
            let value = try? container.decode(String.self, forKey: .value)
        {
            self.value = value
            return
        }
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }
    
    /// Encodes `value` as single contained `String` value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws:  An error if any values are invalid for the given encoder’s format.
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
}

/// The protocol for storing entities in the `UserDefaults`.
protocol UserDefaultsStorable: Equatable, Codable {
    
    /// Defines `UserDefaults` suite - the domain identifier of the search list.
    static var userDefaultsSuiteName: String { get }
    
    /// Defines an array of placeholder items which will be saved to the storage if it's empty.
    static var placeholders: [Self] { get }
    
    /// Return the entity that is current selected one in the implementation.
    /// It can be stored or not yet, this doesn't matter.
    static var currentUntitled: Self? { get }
    
    /// Defines a key in `UserDefaults` for the entity.
    /// Ignored as always equal in synthesized equality check of the entity.
    var title: StorableTitle { get set }
    
    /// Applies the entity so it's going to be `currentUntitled`.
    func apply()
    
}

// MARK: - Generic implementation
extension UserDefaultsStorable {
    
    /// Defines `UserDefaults` storage for this kind of entities.
    static var defaults: UserDefaults {
        let defaults = UserDefaults(suiteName: userDefaultsSuiteName)!
        return defaults
    }
    
    /// Returns an array of all entities found in the associated `UserDefaults` storage.
    /// Will add (save) the `placeholders` array if found no entities before.
    /// The array is sorted by `title`.
    static var stored: [Self] {
        var dataStore: [Data] {
            return defaults.dictionaryRepresentation().values.compactMap { (value) -> Data? in
                return value as? Data
            }
        }
        if dataStore.isEmpty {
            let encoder = JSONEncoder()
            for value in placeholders {
                value.save(with: encoder)
            }
        }
        var values: [Self] = []
        let decoder = JSONDecoder()
        for data in dataStore {
            if let value = try? Self.from(data: data, with: decoder) {
                values.append(value)
            }
        }
        values.sort {
            $0.title.value.localizedCaseInsensitiveCompare($1.title.value) == .orderedAscending
        }
        return values
    }
    
    /// Returns current entity stored with title it stored with.
    /// Or, returns `nil`, if failed to find one in the storage.
    static var currentStored: Self? {
        guard let untitled = currentUntitled else { return nil }
        let stored = self.stored
        if let selectedIndex = stored.index(of: untitled) {
            return stored[selectedIndex]
        }
        return nil
    }
    
    /// Whether the entity is found in the associated `UserDefaults`.
    var isAlreadyStored: Bool {
        return Self.stored.contains(self)
    }
    
    /// Whether the entity is equal to the `currentUntitled` one.
    var isCurrent: Bool {
        return self == .currentUntitled
    }
    
    /// Stores the entity in the  associated `UserDefaults`.
    ///
    /// - Parameter encoder: Encodes the entity to `Data` for storing.
    func save(with encoder: JSONEncoder = .init()) {
        do {
            let data = try self.data(with: encoder)
            Self.defaults.set(data, forKey: title.value)
        } catch {
            print("Failed to save \(self):", error)
        }
    }
    
    /// Removes the entity from the storage.
    func remove() {
        Self.defaults.removeObject(forKey: title.value)
    }
    
    /// Syncronizes the associated `UserDefaults`.
    static func synchronize() {
        defaults.synchronize()
    }
    
    /// Wipes all the data stored in the associated `UserDefaults` domain.
    static func reset() {
        defaults.removePersistentDomain(forName: userDefaultsSuiteName)
    }
    
    /// Whether the entity with given title will rewrite the stored one.
    ///
    /// - Parameter title: title of the entity to match the stored entities with.
    /// - Returns: `true` if entity with given title already stored.
    static func willRewriteOnSave(title: String) -> Bool {
        return Self.defaults.dictionaryRepresentation().keys.contains(title)
    }
    
}



