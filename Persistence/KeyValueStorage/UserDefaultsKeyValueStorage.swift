//
//  UserDefaultsKeyValueStorage.swift
//  OAuthTest
//
//  Created by Michal Štembera on 04/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation

class UserDefaultsKeyValueStorage: KeyValueStorage {
    private let prefix: String
    private let defaults: UserDefaults

    /// - Parameters:
    ///     - prefix: Every key used will be prefixed with this value (if non-empty prefix splitted by dot)
    ///     - defaults: UserDefaults used to read/store all values from/to.
    init(prefix: String = "", defaults: UserDefaults = .standard) {
        self.prefix = prefix
        self.defaults = defaults
    }

    func save(data: Data, for key: String) throws {
        defaults.set(data, forKey: prefixed(key))
    }

    func load(for key: String) throws -> Data {
        if let data = defaults.data(forKey: prefixed(key)) {
            return data
        } else {
            throw KeyValueStorageError.missingData
        }
    }

    func delete(from key: String) throws {
        defaults.removeObject(forKey: prefixed(key))
    }

    private func prefixed(_ key: String) -> String {
        return "\(prefix)\(prefix.isEmpty ? "" : ".")\(key)"
    }
}
