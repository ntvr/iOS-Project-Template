//
//  LoginServicing.swift
//  OAuthTest
//
//  Created by Michal Štembera on 12/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

/// Standardized response for login and refresh API calls
struct TokenResponse: Decodable {
    let token: String
    let expiration: Date
}

/// Provides API calss to login and refresh
protocol LoginServicing {
    /// Logs in user with given username and password
    func login(
        username: String,
        password: String,
        completion: @escaping (Swift.Result<TokenResponse, Error>) -> Void
    )

    /// Refreshes access token with given username and password
    /// The endpoint/route might differ in comparison to login, but will be same most of the times.
    func refresh(
        username: String,
        password: String,
        completion: @escaping (Swift.Result<TokenResponse, Error>) -> Void
    )
}
