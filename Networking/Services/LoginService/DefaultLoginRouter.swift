//
//  LoginRouter.swift
//  OAuthTest
//
//  Created by Michal Štembera on 17/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

struct DefaultLoginRouter: RouterComponents {
    typealias Route = DefaultLoginService.Route

    private let baseURL = "https://www.google.cz" // FIXME: Correct baseURL and other things

    func method(for route: DefaultLoginService.Route) -> HTTPMethod {
        switch route {
        case .login, .refresh:
            return .post
        }
    }

    func url(for route: DefaultLoginService.Route) -> URLConvertible {
        switch route {
        case .login, .refresh:
            return baseURL + "/login"
        }
    }

    func encoding(for route: DefaultLoginService.Route) -> ParameterEncoding {
        switch route {
        case .login, .refresh:
            return JSONEncoding.default
        }
    }

    func parameters(for route: DefaultLoginService.Route) -> Parameters? {
        switch route {
        case let .login(username, password), let .refresh(username, password):
            return [
                "username": username,
                "password": password
            ]
        }
    }

    func headers(for route: DefaultLoginService.Route) -> HTTPHeaders? {
        switch route {
        case .login, .refresh:
            return nil
        }
    }
}
