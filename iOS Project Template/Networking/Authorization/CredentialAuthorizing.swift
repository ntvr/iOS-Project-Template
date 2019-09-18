//
//  TokenAuthorizing.swift
//  OAuthTest
//
//  Created by Michal Štembera on 10/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//
//  Using same formatting as Alamofire so silence warnings
//  swiftlint:disable opening_brace

import Foundation
import Alamofire

/// Authorization using access and resfresh token
class CredentialAuthorizing: Authorizing {
    // Private properties
    private let lock = NSRecursiveLock()
    private var refreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []

    private var credential: CredentialHeaders?
    // Dependencies
    private let credentialProviding: CredentialProviding

    init(credentialProviding: CredentialProviding)
    {
        self.credentialProviding = credentialProviding
        self.credential = credentialProviding.credential

        credentialProviding.credentialEventSource.register(delegate: self, on: .global(qos: .userInitiated))
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
    {
        lock.lock(); defer { lock.unlock() }

        guard let credential = credential else {
            throw AuthorizingError.missingCredential
        }
        guard !credential.hasExpired else {
            throw AuthorizingError.expiredCredential
        }

        var urlRequest = urlRequest

        credential.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }

    func should(
        _ manager: SessionManager,
        retry request: Request,
        with error: Error,
        completion: @escaping RequestRetryCompletion
    ) {
        lock.lock(); defer { lock.unlock() }

        let errorCode = (request.task?.response as? HTTPURLResponse)?.statusCode
        switch (error, errorCode) {
        case (AuthorizingError.missingCredential, _),
             (AuthorizingError.expiredCredential, _),
             (_, 401):
            requestsToRetry.append(completion)

            if !refreshing {
                refreshing = true

                credentialProviding.refreshCredential { [weak self] result in
                    guard let strongSelf = self else { return }
                    strongSelf.lock.lock(); defer { strongSelf.lock.unlock() }

                    if let credential = try? result.get() {
                        strongSelf.credential = credential
                    }

                    strongSelf.refreshing = false
                    strongSelf.requestsToRetry.forEach { $0(result.isSuccess, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        default:
            completion(false, 0.0)
        }
    }
}

// MARK: - CredentialProvidingDelegate
extension CredentialAuthorizing: CredentialProvidingDelegate {
    func credentialProviding(didUpdateCredential credential: CredentialHeaders?) {
        lock.lock(); defer { lock.unlock() }

        self.credential = credential
    }
}
