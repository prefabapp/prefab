//
//  PrefabServer.swift
//  PrefabServer
//
//  Public API for Prefab HTTP Server
//

import Foundation
import HomeKit

/// Main public interface for Prefab HTTP Server
/// 
/// Use this class to start and stop the HomeKit HTTP server in your application.
/// 
/// Example:
/// ```swift
/// let server = PrefabServer()
/// server.start()
/// // Server is now running on port 8080
/// ```
@available(macCatalyst 14.0, *)
public class PrefabServer {
    private let server: Server
    private var serverThread: Thread?
    
    /// Initialize a new PrefabServer instance
    public init() {
        self.server = Server()
    }
    
    /// Start the HTTP server on a background thread
    /// 
    /// The server will:
    /// - Listen on port 8080 at 0.0.0.0
    /// - Advertise via mDNS/Bonjour as "Prefab HomeKit Bridge"
    /// - Provide REST API endpoints for HomeKit data
    public func start() {
        guard serverThread == nil else {
            // Server already started
            return
        }
        
        serverThread = Thread(target: server, selector: #selector(Server.startServer), object: nil)
        serverThread?.start()
    }
    
    /// Stop the HTTP server and advertising
    public func stop() {
        server.stop()
        serverThread = nil
    }
    
    /// Access to the underlying HomeBase for HomeKit data
    public var homeBase: HomeBase {
        return server.homeBase
    }
}

