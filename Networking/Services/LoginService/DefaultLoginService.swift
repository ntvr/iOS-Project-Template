//
//  LoginServicing.swift
//  OAuthTest
//
//  Created by Michal Štembera on 17/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - LoginService - Routing
extension DefaultLoginService {
    enum Route {
        case login(username: String, password: String)
        case refresh(username: String, password: String)
    }
}

/// MARK: - LoginService
/// Exposes API for login endpoints/routes
class DefaultLoginService: LoginService {
    // Public properties
    let sessionManager: SessionManager
    let router: AnyRouter<DefaultLoginService.Route>
    let authorizing: Authorizing?

    /// - Should not have any authorization whatsoever, because login should be publicly accessible.
    /// - Should use shared SessionManager which does not have authorizing already assigned - gets overriden.
    required init<R: Router>(router: R,
                             authorizing: Authorizing? = nil,
                             sessionManager: SessionManager = .default) where R.Route == Route {
        self.authorizing = authorizing
        self.router = AnyRouter(router)
        self.sessionManager = sessionManager
        self.sessionManager.authorizing = authorizing
    }

    func login(username: String,
               password: String,
               completion: @escaping (Swift.Result<TokenResponse, Error>) -> Void) {
        let urlRequest = urlConvertible(for: .login(username: username, password: password))
        sessionManager.request(urlRequest)
            .responseDecodable(type: TokenResponse.self) { completion($0.result.swiftResult) }
    }

    func refresh(username: String,
                 password: String,
                 completion: @escaping (Swift.Result<TokenResponse, Error>) -> Void) {
        let urlRequest = urlConvertible(for: .refresh(username: username, password: password))
        sessionManager.request(urlRequest)
            .responseDecodable(type: TokenResponse.self) { completion($0.result.swiftResult) }
    }
}
