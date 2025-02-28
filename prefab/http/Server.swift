//
//  Server.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation
import OSLog
import Hummingbird

struct HomeKitAuthLogger: HBMiddleware {
    func apply(to request: HBRequest, next: HBResponder) -> EventLoopFuture<HBResponse> {
        let homebase = HomeBase()
        let stats = homebase.homeManager.authorizationStatus
        Logger().log("HomeKit Authorization status is \(stats.rawValue)")
        if !homebase.homeManager.authorizationStatus.contains(.authorized) {
            let failure: EventLoopFuture<HBResponse> = request.failure(.forbidden, message: "{\"error\": \"Prefab is not authorized to access your HomeKit data.\"}")
            
            return failure
        }
        return next.respond(to: request)
    }
}

class Server  {
    var homeBase: HomeBase
    init() {
        homeBase = HomeBase()
        let serverTread = Thread.init(target: self, selector: #selector(startServer), object: HomeBase())
        serverTread.start()
    }
    
    func getRequiredParam(param: String, request: HBRequest) throws -> String {
        guard let value = request.parameters[param] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid \(param) parameter."
            )
        }
        return value
    }
    
    @objc
    func startServer(homeStore: HomeBase) {
        Task{
            let app = HBApplication(configuration: .init(address: .hostname("127.0.0.1", port: 8080)))
            app.logger.logLevel = .debug
            app.middleware.add(HBLogRequestsMiddleware(.debug))
            app.middleware.add(HomeKitAuthLogger())
            app.router.get("homes", use: self.getHomes)
            app.router.get("homes/:home", use: self.getHome)
           
            app.router.get("rooms/:home", use: self.getRooms)
            app.router.get("rooms/:home/:room", use: self.getRoom)
            
            app.router.get("accessories/:home/:room", use: self.getAccessories)
            app.router.get("accessories/:home/:room/:accessory", use: self.getAccessory)
            app.router.put("accessories/:home/:room/:accessory", use: self.updateAccessory)
            
            
            try app.start()
            await app.asyncWait()
        }
    }
}
