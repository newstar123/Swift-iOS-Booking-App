//
//  CodableExtension.swift
//  Qorum
//
//  Created by Stanislav on 18.09.2018.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation

extension JSONEncoder {
    
    /// returns encoder to produce human-readable JSON with indented output.
    static var prettyPrinting: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if #available(iOS 11.0, *) {
            encoder.outputFormatting.insert(.sortedKeys)
        }
        return encoder
    }
    
}

extension Encodable {
    
    /// Encodes value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Returns: Encoded data
    /// - Throws: Throws an error if any values are invalid for the given encoder's format.
    func data(with encoder: JSONEncoder = .init()) throws -> Data {
        return try encoder.encode(self)
    }
    
    func jsonString(with encoder: JSONEncoder = .prettyPrinting) -> String {
        do {
            let data = try self.data(with: encoder)
            if let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
            return "no string"
        } catch {
            print(error)
            return "no data"
        }
    }
    
}
extension Decodable {
    
    /// Creates a new instance by decoding data from the given decoder
    ///
    /// - Parameters:
    ///   - data: Data to decode
    ///   - decoder: The decoder to read data from
    /// - Returns: Decoded instance
    /// - Throws: Throws an error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid
    static func from(data: Data,
                     with decoder: JSONDecoder = .init()) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
    
    /// Creates a new instance by decoding data from the given decoder
    ///
    /// - Parameters:
    ///   - jsonString: JSON string to decode
    ///   - decoder: The decoder to read data from
    /// - Returns: Decoded instance
    /// - Throws: Throws an error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid
    static func from(jsonString: String,
                     with decoder: JSONDecoder = .init()) throws -> Self {
        guard let data = jsonString.data(using: .utf8) else {
            throw DecodingError.valueNotFound(Data.self, .init(codingPath: [],
                                                               debugDescription: "Data missing for \"\(jsonString)\" string"))
        }
        return try from(data: data, with: decoder)
    }
    
}

