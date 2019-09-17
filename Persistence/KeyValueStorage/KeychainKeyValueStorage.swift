//
//  KeychainAdapter.swift
//  OAuthTest
//
//  Created by Michal Štembera on 04/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation

private typealias KeychainQuery = [String: AnyObject]

final class KeychainKeyValueStorage: KeyValueStorage {
    let serviceIdentifier: String
    let biometricAuthRequired: Bool

    init(serviceIdentifier: String, biometricAuthRequired: Bool) {
        self.serviceIdentifier = serviceIdentifier
        self.biometricAuthRequired = biometricAuthRequired
    }

    func load(for key: String) throws -> Data {
        let queryResult: AnyObject? = try getResult(account: key, single: true)

        guard let item = queryResult as? KeychainQuery else {
            throw  KeyValueStorageError.missingData
        }
        guard let data = item[kSecValueData as String] as? Data else {
            throw KeyValueStorageError.invalidData
        }

        return data
    }

    func save(data: Data, for key: String) throws {
        // delete item if already exists
        var deleteQuery = getQuery(account: key)
        deleteQuery[kSecReturnData as String] = kCFBooleanFalse
        SecItemDelete(deleteQuery as CFDictionary)

        var newQuery = getQuery(account: key)
        newQuery[kSecValueData as String] = data as AnyObject
        if biometricAuthRequired {
            let sacObject = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                .userPresence, nil)
            newQuery[kSecAttrAccessControl as String] = sacObject!
        }

        let status = SecItemAdd(newQuery as CFDictionary, nil)

        if status != noErr {
            throw KeyValueStorageError.failingOSStatus(code: status)
        }
    }

    func delete(from key: String) throws {
        let query = getQuery(account: key)
        let status = SecItemDelete(query as CFDictionary)

        if status != noErr {
            throw KeyValueStorageError.failingOSStatus(code: status)
        }
    }

    private func getResult(account: String? = nil,
                           single: Bool,
                           biometricAuthMessage: String? = nil) throws -> AnyObject? {
        var query = getQuery(account: account)
        query[kSecMatchLimit as String] = single ? kSecMatchLimitOne : kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        if biometricAuthRequired {
            query[kSecUseOperationPrompt as String] = (biometricAuthMessage ?? "Authenticate to login") as AnyObject
        }

        // fetch the existing keychain item that matches the query
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // handle errors
        if status == errSecItemNotFound {
            throw KeyValueStorageError.missingData
        }
        if status != noErr {
            throw KeyValueStorageError.failingOSStatus(code: status)
        }

        return queryResult
    }

    private func getQuery(account: String? = nil) -> KeychainQuery {
        var query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier as AnyObject
        ]
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }
        return query
    }
}
