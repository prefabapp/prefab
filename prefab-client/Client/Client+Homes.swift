//
//  Homes.swift
//  Prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation


extension Client {
    public func getHomes() async throws -> String {
        return try await get(path: "/homes")
    }
    
    public func getHome(name: String) async throws -> String {
        return try await get(path: "/homes/\(name)")
    }
}
