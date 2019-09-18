//
//  AlamofireResult+SwiftResult.swift
//  OAuthTest
//
//  Created by Michal Štembera on 12/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

extension Alamofire.Result {
    /// Convert Alamofire.Result to Swift.Result with generic Error.
    var swiftResult: Swift.Result<Value, Error> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Swift.Result {
    /// Returns true when state is .success, false otherwise.
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
