//
//  Application+Testable.swift
//  VaporTestTools
//
//  Created by Ondrej Rafaj on 27/02/2018.
//

import Foundation
import Vapor
import Routing

/// Response tuple containing response as well as the request
public typealias TestResponse = (response: Response, request: Request)


extension TestableProperty where TestableType: Application {
    
    public typealias AppConfigClosure = ((_ config: inout Config, _ env: inout Vapor.Environment, _ services: inout Services) -> Void)
    public typealias AppRouterClosure = ((_ router: Router) -> Void)
    
    /// Configure a new test app (in test setup)
    public static func new(config: Config = Config.default(), env: Environment? = nil, services: Services = Services.default(), _ configClosure: AppConfigClosure? = nil, _ routerClosure: AppRouterClosure) -> Application {
        var config = config
        var env = try! env ?? Environment.detect()
        var services = services
        
        configClosure?(&config, &env, &services)
        let app = try! Application(config: config, environment: env, services: services)
        
        let router = try! app.make(Router.self)
        routerClosure(router)
        
        return app
    }
    
    /// Respond to HTTPRequest
    public func response(to request: HTTPRequest) -> TestResponse {
        let responder = try! element.make(Responder.self)
        let wrappedRequest = Request(http: request, using: element)
        return try! (response: responder.respond(to: wrappedRequest).wait(), request: wrappedRequest)
    }
    
    /// Respond to HTTPRequest (throwing)
    public func response(throwingTo request: HTTPRequest) throws -> TestResponse {
        let responder = try element.make(Responder.self)
        let wrappedRequest = Request(http: request, using: element)
        return try (response: responder.respond(to: wrappedRequest).wait(), request: wrappedRequest)
    }
    
    /// Create fake request
    public func fakeRequest() -> Request {
        let http = HTTPRequest(method: .GET, url: URL(string: "/")!)
        let req = Request(http: http, using: element)
        return req
    }
    
}

