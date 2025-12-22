//
//  Server.swift
//  PrefabServer
//
//  Internal server implementation
//

import Foundation
import OSLog
import Hummingbird

// BonjourAdvertiser: manage NetService creation, TXT record, publish, retries on name conflict.
final class BonjourAdvertiser: NSObject, NetServiceDelegate {
	private var service: NetService?
	private let baseName: String
	private let serviceType: String
	private let port: Int32
	private let txtData: [String: String]
	private var attempt = 0

	init(name: String, type: String, port: Int32, txt: [String:String]) {
		self.baseName = name
		self.serviceType = type
		self.port = port
		self.txtData = txt
		super.init()
		createService(name: name)
	}
	
	private func createService(name: String) {
		let cleanType = serviceType.trimmingCharacters(in: .whitespacesAndNewlines)
		let svc = NetService(domain: "", type: cleanType, name: name, port: port)
		// Don't set peer-to-peer for initial testing
		// svc.includesPeerToPeer = true
		let txtDict = txtData.reduce(into: [String: Data]()) { $0[$1.key] = $1.value.data(using: .utf8) }
		svc.setTXTRecord(NetService.data(fromTXTRecord: txtDict))
		svc.delegate = self
		self.service = svc
	}

	func publish() {
		let cleanType = serviceType.trimmingCharacters(in: .whitespacesAndNewlines)
		print("🔎 Publishing Bonjour service: \(service?.name ?? "unknown") type: \(cleanType) port: \(service?.port ?? 0)")
		service?.publish()
	}

	func stop() {
		service?.stop()
		service = nil
	}

	// Optional: accept connections if using NetService sockets; here we only advertise HTTP on port.
	func netServiceDidPublish(_ sender: NetService) {
		let cleanType = sender.type.trimmingCharacters(in: .whitespacesAndNewlines)
		let cleanDomain = sender.domain.trimmingCharacters(in: .whitespacesAndNewlines)
		print("✅ Bonjour published: \(cleanType) \(sender.name).\(cleanDomain)")
	}
	func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
		if let errorCode = errorDict["NSNetServicesErrorCode"]?.intValue {
			switch errorCode {
			case -72003: // kDNSServiceErr_NameConflict
				attempt += 1
				let newName = attempt == 1 ? "\(baseName) (2)" : "\(baseName) (\(attempt + 1))"
				print("⚠️  Name conflict, retrying as '\(newName)'")
				createService(name: newName)
				publish()
				return
			default:
				print("❌ Bonjour error: \(errorDict)")
			}
		} else {
			print("❌ Bonjour error: \(errorDict)")
		}
	}
}

struct HomeKitAuthLogger: HBMiddleware {
    func apply(to request: HBRequest, next: HBResponder) -> EventLoopFuture<HBResponse> {
        let homebase = HomeBase.shared
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
    private var bonjourAdvertiser: BonjourAdvertiser?
    private var app: HBApplication?
    
    init() {
        self.homeBase = HomeBase.shared
    }
    
    deinit {
        stop()
    }
    
    private func startAdvertising() {
        // Create and configure the BonjourAdvertiser for mDNS advertising
        let txtData: [String: String] = [
            "server": "prefab",
            "version": "1.0",
            "api": "homekit"
        ]
        
        bonjourAdvertiser = BonjourAdvertiser(name: "Prefab HomeKit Bridge", type: "_prefab._tcp.", port: 8080, txt: txtData)
        bonjourAdvertiser?.publish()
        Logger().info("Started mDNS advertising for Prefab HomeKit Server on port 8080")
    }
    
    private func stopAdvertising() {
        bonjourAdvertiser?.stop()
        bonjourAdvertiser = nil
        Logger().info("Stopped mDNS advertising")
    }
    
    func stop() {
        stopAdvertising()
        // Note: HBApplication doesn't have a direct stop method in this version
        // The server will stop when the thread exits
        app = nil
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
    func startServer() {
        Task{
            let application = HBApplication(configuration: .init(address: .hostname("0.0.0.0", port: 8080)))
            self.app = application
            application.logger.logLevel = .debug
            application.middleware.add(HBLogRequestsMiddleware(.debug))
            application.middleware.add(HomeKitAuthLogger())
            application.router.get("homes", use: self.getHomes)
            application.router.get("homes/:home", use: self.getHome)
           
            application.router.get("rooms/:home", use: self.getRooms)
            application.router.get("rooms/:home/:room", use: self.getRoom)
            
            application.router.get("accessories/:home/:room", use: self.getAccessories)
            application.router.get("accessories/:home/:room/:accessory", use: self.getAccessory)
            application.router.put("accessories/:home/:room/:accessory", use: self.updateAccessory)
            
            application.router.get("scenes/:home", use: self.getScenes)
            application.router.get("scenes/:home/:scene", use: self.getScene)
            application.router.post("scenes/:home/:scene/execute", use: self.executeScene)
            
            application.router.get("groups/:home", use: self.getGroups)
            application.router.get("groups/:home/:group", use: self.getGroup)
            application.router.put("groups/:home/:group", use: self.updateGroup)
            
            // Start mDNS advertising
            startAdvertising()
            
            try application.start()
            RunLoop.current.add(Port(), forMode: .default)
            while true { RunLoop.current.run(mode: .default, before: Date.distantFuture) }
            await application.asyncWait()
        }
    }
}

