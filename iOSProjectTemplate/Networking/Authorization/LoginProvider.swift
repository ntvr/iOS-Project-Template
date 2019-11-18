//
//  LoginProvider.swift
//  OAuthTest
//
//  Created by Michal Štembera on 13/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation

// MARK: - Internal representation of LoginCredentials and LoginStatus
private struct LoginCredentials: Codable {
    let accessToken: String
    let accessTokenExpiration: Date
    let username: String
    let password: String

    var credentialHeaders: CredentialHeaders {
        return CredentialHeaders(accessToken: accessToken, expiration: accessTokenExpiration)
    }
}
private enum LoginStatus {
    case loggedIn(credentials: LoginCredentials)
    case loggedOut
}

// MARK: - LoginProvider
/// Provides regular login behaviour using credentials for initial token retriaval and refresh
class LoginProvider: LoginProviding {
    // Private propeties
    private let lock = NSRecursiveLock()
    private let credentialStorage: SingleKeyValueStorage<LoginCredentials>
    private let loginService: LoginServicing
    private var loginStatus: LoginStatus
    // Public properties
    let loginEventSource = EventSource<LoginProvidingDelegate>()
    let credentialEventSource = EventSource<CredentialProvidingDelegate>()
    var loggedIn: Bool {
        switch loginStatus {
        case .loggedIn:
            return true
        case .loggedOut:
            return false
        }
    }
    var username: String? {
        switch loginStatus {
        case let .loggedIn(credentials):
            return credentials.username
        case .loggedOut:
            return nil
        }
    }

    init(
        loginService: LoginServicing,
        // FIXME: Provide correct group identifier
        keychainServiceIdentifier: String = "com.stembera.michal.login.provider"
    ) {
        self.loginService = loginService

        let credentialStorage = SingleKeyValueStorage<LoginCredentials>(
            key: "login.credential",
            storage: KeychainKeyValueStorage(
                serviceIdentifier: keychainServiceIdentifier,
                biometricAuthRequired: false
            )
        )
        self.credentialStorage = credentialStorage

        if let credentials = credentialStorage.value {
            loginStatus = .loggedIn(credentials: credentials)
        } else {
            loginStatus = .loggedOut
        }
    }

    func login(username: String, password: String, completion: @escaping (Swift.Result<Void, Error>) -> Void) {
        loginService.login(username: username, password: password) { [weak self] result in
            guard let strongSelf = self else {
                completion(.failure(CredentialProvidingError.resourceReleased))
                return
            }
            strongSelf.lock.lock(); defer { strongSelf.lock.unlock() }

            switch result {
            case let .success(tokenResponse):
                let newCredentials = LoginCredentials(
                    accessToken: tokenResponse.token,
                    accessTokenExpiration: tokenResponse.expiration,
                    username: username,
                    password: password
                )
                strongSelf.loginStatus = .loggedIn(credentials: newCredentials )
                strongSelf.credentialStorage.value = newCredentials
                completion(.success(()))
                strongSelf.loginEventSource
                    .notifyDelegates { $0.loginProviding(didLoginWith: newCredentials .username) }
                strongSelf.credentialEventSource
                    .notifyDelegates { $0.credentialProviding(didUpdateCredential: newCredentials.credentialHeaders) }
            case let .failure(error):
                completion(.failure(error))
                strongSelf.loginEventSource
                    .notifyDelegates { $0.loginProviding(didFailToLoginWith: username, error: error) }
            }
        }
    }

    func logout() {
        lock.lock(); defer { lock.unlock() }

        credentialStorage.value = nil
        loginStatus = .loggedOut
        loginEventSource.notifyDelegates { $0.loginProvidingDidLogout() }
        credentialEventSource.notifyDelegates { $0.credentialProviding(didUpdateCredential: nil) }
    }
}

// MARK: - CredentialProviding
extension LoginProvider: CredentialProviding {
    var credential: CredentialHeaders? {
        switch loginStatus {
        case let .loggedIn(credentials):
            return credentials.credentialHeaders
        case .loggedOut:
            return nil
        }
    }

    func refreshCredential(completion: @escaping (Swift.Result<CredentialHeaders, Error>) -> Void) {
        guard case let .loggedIn(credentials) = loginStatus else {
            completion(.failure(CredentialProvidingError.refreshUnavailable))
            return
        }

        loginService.refresh(username: credentials.username, password: credentials.password) { [weak self] result in
            guard let strongSelf = self else {
                completion(.failure(CredentialProvidingError.resourceReleased))
                return
            }
            strongSelf.lock.lock(); defer { strongSelf.lock.unlock() }

            switch result {
            case let .success(tokenResponse):
                let newCredentials = LoginCredentials(
                    accessToken: tokenResponse.token,
                    accessTokenExpiration: tokenResponse.expiration,
                    username: credentials.username,
                    password: credentials.password
                )
                strongSelf.credentialStorage.value = newCredentials
                completion(.success(newCredentials.credentialHeaders))
                strongSelf.credentialEventSource
                    .notifyDelegates { $0.credentialProviding(didUpdateCredential: newCredentials.credentialHeaders) }
            case let .failure(error):
                completion(.failure(error))
                strongSelf.credentialEventSource
                    .notifyDelegates { $0.credentialProviding(didUpdateCredential: nil) }
            }
        }
    }
}
