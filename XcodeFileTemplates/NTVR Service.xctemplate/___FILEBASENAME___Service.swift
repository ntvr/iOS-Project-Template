//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import Foundation
import Alamofire

class ___VARIABLE_productName___Service: ___VARIABLE_productName___Servicing, Service {
    enum Route {
    }

    let sessionManager: SessionManager
    let authorizing: Authorizing?
    let router: AnyRouter<___VARIABLE_productName___Service.Route>

    required init<R: Router>(
        router: R,
        authorizing: Authorizing?,
        sessionManager: SessionManager
    ) where R.Route == Route {
        self.authorizing = authorizing
        self.router = AnyRouter(router)
        self.sessionManager = sessionManager
        self.sessionManager.authorizing = authorizing
    }

    func <#function#>(completion: @escaping (Swift.Result<<#Model#>, Error>) -> Void) {
        sessionManager
            .request(urlConvertible(for: <#Route#>))
            .responseDecodable(type: <#Model#>.self) { completion($0.result.swiftResult) }
    }
}
