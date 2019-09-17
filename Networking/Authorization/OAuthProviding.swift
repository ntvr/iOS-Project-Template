//
//  OAuthProviding.swift
//  OAuthTest
//
//  Created by Michal Štembera on 04/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ApplicationURLHandling: WeakBoxValue {
    /// Process opened URL from another app, parse out the data, if not interested return.
    /// - For security measures it should be checked whether the source app is Safari
    /// - Returns: Flag whether the URL was handled or not
    func handleOpened(url: URL,
                      by app: UIApplication,
                      with options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}
extension ApplicationURLHandling {
    /// Checks whether the app was opened by Safari
    static func openedBySafari(options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return options[.sourceApplication] as? String == "com.apple.SafariViewService"
            || options[.sourceApplication] as? String == "com.apple.mobilesafari"
    }
}

/// CredentialProviding associated errors
enum CredentialProvidingError: Error {
    case refreshUnavailable
    case resourceReleased
}

/// Notifies delegate aboout the change of the tokens
@objc protocol CredentialProvidingDelegate: WeakBoxValue {
    /// TokenProviding did update to new Token
    /// - TokenProviding cannot be interpreted in ObjC
    func credentialProviding(didUpdateCredential credential: CredentialHeaders?)
}

/// Provides tokens for authorization purposes
protocol CredentialProviding {
    /// Available tokens
    var credential: CredentialHeaders? { get }

    /// TokenAuhtorizing (or others) can register to receive token updates
    var credentialEventSource: EventSource<CredentialProvidingDelegate> { get }

    /// Refreshes the access token using correct API and refresh token
    func refreshCredential(completion: @escaping (Swift.Result<CredentialHeaders, Error>) -> Void)
}

/// Handles OAuth authorization and provide necessary information to do so.
protocol OAuthProviding: ApplicationURLHandling, CredentialProviding {
    /// Scheme of the URI to which the response will be redirected
    var redirectURI: String { get }

    /// Starts OAuth Authentication through system browser or other method.
    func requestAccess() throws
}
