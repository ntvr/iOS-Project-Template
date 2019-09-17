//
//  SessionManager+Authorizing.swift
//  OAuthTest
//
//  Created by Michal Štembera on 12/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

extension SessionManager {
    /// Authorizing service as adapter and retrier of SessionManager - can be set at once
    var authorizing: Authorizing? {
        get {
            let adapter = self.adapter as? Authorizing
            let retrier = self.retrier as? Authorizing
            return adapter === retrier ? adapter : nil
        }
        set { self.adapter = newValue; self.retrier = newValue }
    }
}
