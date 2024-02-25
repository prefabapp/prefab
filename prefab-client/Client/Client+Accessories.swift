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
        return try await get(path: "/accessories/\(home)/\(room)/\(name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
    }
    
    public func updateAccessory(name: String, home: String, room: String, serviceId: String, characteristicId: String, value: Any) async throws -> String {
        let updateAccessoryInput: UpdateAccessoryInput = UpdateAccessoryInput(serviceId: serviceId, characteristicId: characteristicId, value: value as! String)
        return try await put(path: "/accessories/\(home)/\(room)/\(name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)", data: updateAccessoryInput)
    }
}

