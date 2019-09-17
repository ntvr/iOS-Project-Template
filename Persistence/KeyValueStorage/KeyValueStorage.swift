//
//  KeyValueStorage.swift
//  OAuthTest
//
//  Created by Michal Štembera on 04/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation

/// Potential errors that can occur during read/write operations
enum KeyValueStorageError: Error {
    case missingData
    case invalidData
    case failingOSStatus(code: OSStatus)
}

/// Single Value wrapper to enable encoding and decoding of single primitive into JSON.
/// - JSON serialization does not support top level fragments as of now.
struct Primitive<T: Codable>: Codable {
    let primitive: T

    init(_ primitive: T) {
        self.primitive = primitive
    }
}

protocol KeyValueStorage {
    /// Load data from underlying storage from given key
    func load(for key: String) throws -> Data

    /// Store data into underlying storage under given key
    func save(data: Data, for key: String) throws

    /// Deletes data stored under provided key
    func delete(from key: String) throws
}

extension KeyValueStorage {
    /// Load provided Decodable from data under given key
    func load<T>(_ type: T.Type, for key: String) throws -> T where T: Decodable {
        let data = try load(for: key)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Save provided Encodable into data under given key
    func save<T>(value: T, for key: String) throws where T: Encodable {
        let data = try JSONEncoder().encode(value)
        try save(data: data, for: key)
    }
}
