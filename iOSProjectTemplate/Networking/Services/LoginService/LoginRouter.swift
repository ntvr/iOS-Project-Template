//
//  LoginRouter.swift
//  OAuthTest
//
//  Created by Michal Štembera on 17/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

struct LoginRouter: RouterComponents {
    typealias Route = LoginService.Route

    private let baseURL = "https://www.google.cz" // FIXME: Correct baseURL and other things

    func method(for route: LoginService.Route) -> HTTPMethod {
        switch route {
        case .login, .refresh:
            return .post
        }
    }

    func url(for route: LoginService.Route) -> URLConvertible {
        switch route {
        case .login, .refresh:
            return baseURL + "/login"
        }
    }

    func encoding(for route: LoginService.Route) -> ParameterEncoding {
        switch route {
        case .login, .refresh:
            return JSONEncoding.default
        }
    }

    func parameters(for route: LoginService.Route) -> Parameters? {
        switch route {
        case let .login(username, password), let .refresh(username, password):
            return [
                "username": username,
                "password": password
            ]
        }
    }

    func headers(for route: LoginService.Route) -> HTTPHeaders? {
        switch route {
        case .login, .refresh:
            return nil
        }
    }
}
