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
    private var netService: NetService?
    
    init() {
        homeBase = HomeBase()
        let serverThread = Thread.init(target: self, selector: #selector(startServer), object: HomeBase())
        serverThread.start()
    }
    
    deinit {
        stopAdvertising()
    }
    
    private func startAdvertising() {
        // Create and configure the NetService for mDNS advertising
        let txtData: [String: Data] = [
            "server": "prefab".data(using: .utf8)!,
            "version": "1.0".data(using: .utf8)!,
            "api": "homekit".data(using: .utf8)!
        ]
        
        netService = NetService(domain: "", type: "_http._tcp.", name: "Prefab HomeKit Bridge", port: 8080)
        let txtRecord = NetService.data(fromTXTRecord: txtData)
        netService?.setTXTRecord(txtRecord)
        
        guard let service = netService else {
            Logger().error("Failed to create NetService")
            return
        }
        
        // Start advertising
        service.publish()
        Logger().info("Started mDNS advertising for Prefab HomeKit Server on port 8080")
    }
    
    private func stopAdvertising() {
        netService?.stop()
        netService = nil
        Logger().info("Stopped mDNS advertising")
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
            let app = HBApplication(configuration: .init(address: .hostname("0.0.0.0", port: 8080)))
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
            
            // Start mDNS advertising
            startAdvertising()
            
            try app.start()
            await app.asyncWait()
        }
    }
}
