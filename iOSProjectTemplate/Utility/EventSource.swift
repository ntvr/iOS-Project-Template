//
//  MultiDelegate.swift
//  OAuthTest
//
//  Created by Michal Štembera on 06/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation

/// Used to restrict protocol to be only for classes.
@objc public protocol WeakBoxValue: class {}

/// Wraps value in a weak property, in case where it cannot be done, like an Array...
public class WeakBox<BoxValue: WeakBoxValue> {
    private(set) weak var value: BoxValue?

    init(value: BoxValue?) {
        self.value = value
    }
}

/// Wraps multiple delegates on single delegation
class EventSource<Protocol> where Protocol: WeakBoxValue {
    // Private types
    private typealias DelegatePair = (delegate: WeakBox<Protocol>, queue: DispatchQueue)
    // Private properties
    private let lock = NSLock()
    private var delegates: [DelegatePair] = []

    /// Registers to receive delegate calls on queue provided, no need to unregister
    ///
    /// - Parameters:
    ///     - delegate: Delegate to be notified about login status changes. Receives initial call.
    ///     - queue: Queue on that the delegate call will be executed.
    func register(delegate: Protocol, on queue: DispatchQueue = .main) {
        lock.lock(); defer { lock.unlock() }

        let pair: DelegatePair = (WeakBox(value: delegate), queue)
        self.delegates.append(pair)
    }

    /// Unregisters from receiving delegate calls
    func unregister(delegate: WeakBoxValue) {
        lock.lock(); defer { lock.unlock() }

        self.delegates = self.delegates.filter { $0.delegate.value !== delegate }
    }

    func notifyDelegates(with notify: @escaping (Protocol) -> Void) {
        lock.lock(); defer { lock.unlock() }

        cleanupReleased()
        delegates.forEach { pair in
            guard let delegate = pair.delegate.value else {
                return
            }
            pair.queue.async { notify(delegate) }
        }
    }

    // MARK: - Private workers
    private func cleanupReleased() {
        self.delegates = delegates.filter { $0.delegate.value != nil }
    }
}
