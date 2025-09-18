//
//  main.swift
//  prefab-client
//
//  Created by Kelly Plummer on 2/15/24.
//

import Foundation
import ArgumentParser

@main
struct Prefab: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "prefab",
        abstract: "A tool for interacting with homes.",
        usage: """
            prefab command
            """,
        discussion: """
            Automatically discovers Prefab HomeKit Bridge servers via mDNS, 
            or falls back to localhost:8080 if none found.
            """,
        subcommands: [GetHomes.self, GetHome.self, GetRooms.self, GetRoom.self, GetAccessory.self, GetAccessories.self, UpdateAccessory.self])

    @Flag(name: .shortAndLong, help: "Use localhost:8080 instead of mDNS discovery.")
    var localhost = false
    
    static var client: Client?
    
    static func getClient() async throws -> Client {
        if let existingClient = client {
            return existingClient
        }
        
        // Try mDNS discovery first, then fall back to localhost
        do {
            print("Discovering Prefab HomeKit Bridge servers...")
            client = try await Client.initSharedWithDiscovery()
            print("Found server at \(client!.host):\(client!.port)")
        } catch {
            print("mDNS discovery failed (\(error.localizedDescription)), using localhost:8080")
            client = Client.initShared(host: "localhost", port: "8080", scheme: "http")
        }
        
        return client!
    }
    
    static func getClientWithLocalhost() -> Client {
        if client == nil {
            client = Client.initShared(host: "localhost", port: "8080", scheme: "http")
        }
        return client!
    }

//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false

//    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
//    var count: Int? = nil

//    @Argument(help: "The phrase to repeat.")
//    var phrase: String


}
