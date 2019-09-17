//
//  LoginProvider.swift
//  OAuthTest
//
//  Created by Michal Štembera on 12/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

// Cannot have LoginProvider as parameter as it cannot be exposed to objective-C because of LoginStatus
@objc protocol LoginProvidingDelegate: WeakBoxValue {
    /// Called on delegate when user logged in using pin. Gets called on dedicated (non-main) queue.
    func loginProviding(didLoginWith username: String)

    /// Notify delegates about failed login, they might need to delete some temporary data
    func loginProviding(didFailToLoginWith username: String, error: Error)

    /// Called on delegate when user logged out. Gets called on dedicated (non-main) queue.
    func loginProvidingDidLogout()
}

/// Provides a login and logout functionality for the app
protocol LoginProviding: class, CredentialProviding {
    /// Flag whether the user is logged in or not
    var loggedIn: Bool { get }
    /// If logged in then contains username, otherwise nil
    var username: String? { get }
    /// Source when the delegate can register for changes
    var loginEventSource: EventSource<LoginProvidingDelegate> { get }

    /// Login the user using username and password
    func login(username: String, password: String, completion: @escaping (Swift.Result<Void, Error>) -> Void)
    /// Logs out the currently logged user
    func logout()
}
