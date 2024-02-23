//
//  Client+Accessories.swift
//  prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation

extension Client {
    public func getAccessories(home: String, room: String) async throws -> String {
        return try await get(path: "/accessories/\(home)/\(room)")
    }
    
    public func getAccessory(name: String, home: String, room: String) async throws -> String {
        return try await get(path: "/accessories/\(home)/\(room)/\(name)")
    }
}

