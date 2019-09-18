//
//  SingleKeyValueStorage.swift
//  OAuthTest
//
//  Created by Michal Štembera on 04/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation

/// Wrapper around storage exposing only single value.
/// - Uses different storage internally. can be anything implementing KeyValueStorage.
/// - Recommended underelying storages are UserDefaultsKeyValueStorage or KeychainKeyValueStorage
class SingleKeyValueStorage<Value: Codable> {
    internal let key: String
    internal let storage: KeyValueStorage

    /// Stored underlying value
    var value: Value? {
        get { return try? load() }
        set { try? save(value: newValue) }
    }

    /// - Parameters:
    ///     - key: Key to be used for retrieving and storing the value
    ///     - storage: Underlying storage where the value will be stored
    init(key: String, storage: KeyValueStorage) {
        self.key = key
        self.storage = storage
    }

    /// Loads the value, throws error if not found
    /// - You can use `value` if not interested in error
    func load() throws -> Value {
        return try storage.load(Value.self, for: key)
    }

    /// Loads the value, throws error if unsuccessful
    /// - You can use `value` if not interested in error
    func save(value: Value?) throws {
        if let value = value {
            try storage.save(value: value, for: key)
        } else {
            try storage.delete(from: key)
        }
    }
}
