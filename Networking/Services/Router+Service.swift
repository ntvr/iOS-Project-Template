//
//  ServiceProtocols.swift
//  OAuthTest
//
//  Created by Michal Štembera on 12/09/2019.
//  Copyright © 2019 Michal Štembera. All rights reserved.
//

import Foundation
import Alamofire

/// - Router protocol for concrete Route which is suggested to be an enum.
/// - Creates URLRequest for given route of type Route.
protocol Router {
    associatedtype Route

    func urlRequest(for route: Route) throws -> URLRequestConvertible
}

/// Additional way how to conform to Router in standardized way
/// - Provide each of the components by itself and benefit from implemented urlRequest(for:)
protocol RouterComponents: Router {
    func method(for route: Route) -> HTTPMethod
    func url(for route: Route) -> URLConvertible
    func headers(for route: Route) -> HTTPHeaders?
    func parameters(for route: Route) -> Parameters?
    func encoding(for route: Route) -> ParameterEncoding
}
extension RouterComponents {
    func urlRequest(for route: Route) throws -> URLRequestConvertible {
        let request = try URLRequest(
            url: url(for: route),
            method: method(for: route),
            headers: headers(for: route))
        return try encoding(for: route)
            .encode(request, with: parameters(for: route))
    }
}

/// Type erased Router for concrete Route
struct AnyRouter<Route>: Router {
    private let urlRequestForRoute: (Route) throws -> URLRequestConvertible

    init<R: Router>(_ router: R) where R.Route == Route {
        self.urlRequestForRoute = router.urlRequest(for:)
    }

    func urlRequest(for route: Route) throws -> URLRequestConvertible {
        return try urlRequestForRoute(route)
    }
}

/// General service definition
protocol Service: class {
    associatedtype Route

    /// Own session manager with Authorizing setup.
    var sessionManager: SessionManager { get }
    /// Router to translate associated enum Route into URLRequests.
    ///
    /// Example of potential `init` implementation to enable Router associated type erasure.
    ///
    /// ```
    ///    init<R: Router>(_ router: R, authorizing: Authorizing?) where R.Route == Self.Route {
    ///        self.router = AnyRouter<Route>(router)
    ///    }
    /// ```
    var router: AnyRouter<Route> { get }
    /// Provider for authorization for underlying session
    var authorizing: Authorizing? { get }

}
extension Service {
    /// - Wraps route and router into RouteToURLConvertor which implements URLRequestConvertible.
    /// - Meant for use with Alamofire to leverage its error handling.
    func urlConvertible(for route: Route) -> URLRequestConvertible {
        return RouteToURLConvertor(route: route, router: router)
    }
}

/// Wrapper around URLRequest creation to be able to use Alamofire's handling of errors
private struct RouteToURLConvertor<Route>: URLRequestConvertible {
    private let route: Route
    private let router: AnyRouter<Route>

    init(route: Route, router: AnyRouter<Route>) {
        self.route = route
        self.router = router
    }

    func asURLRequest() throws -> URLRequest {
        return try router.urlRequest(for: route).asURLRequest()
    }
}
