//
//  Client+Rooms.swift
//  prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation

extension Client {
    public func getRooms(home: String) async throws -> String {
        return try await get(path: "/rooms/\(home)")
    }
    
    public func getRoom(name: String, home: String) async throws -> String {
        return try await get(path: "/rooms/\(home)/\(name)")
    }
}
