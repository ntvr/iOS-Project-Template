//
//  Authorizing.swift
//  OAuthTest
//
//  Created by Michal Štembera on 04/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - AuthorizingError
enum AuthorizingError: Error {
    case missingCredential
    case expiredCredential
}

/// AccesToken has to be class to be exposeable to ObjC
@objc
class CredentialHeaders: NSObject {
    let headers: [String: String]
    let expiration: Date?

    init(headers: [String: String], expiration: Date?) {
        self.headers = headers
        self.expiration = expiration
    }

    init(accessToken: String, expiration: Date?) {
        self.headers = ["Authorization": "Bearer \(accessToken)"]
        self.expiration = expiration
    }

    var hasExpired: Bool {
        guard let expiration = expiration else {
            return false
        }
        return Date() >= expiration
    }
}

/// Abstract authorization to be used with Alamofire
protocol Authorizing: class, RequestAdapter, RequestRetrier {}
