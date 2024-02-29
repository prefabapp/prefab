//
//  Routes+Rooms.swift
//  Prefab
//
//  Created by kelly on 2/25/24.
//

import Foundation
import Hummingbird

extension Server {
    func getRooms(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        let home = homeBase.homes.first(where: {$0.name == homeName.removingPercentEncoding})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let rooms = home?.rooms.map{Room(home: home!.name, name: $0.name)}
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(rooms)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    func getRoom(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        let roomName = try getRequiredParam(param: "room", request: request)
        let home = homeBase.homes.first(where: {$0.name == homeName.removingPercentEncoding})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let room = home?.rooms.first(where: {$0.name == roomName.removingPercentEncoding})
        if (room == nil) {
            throw HBHTTPError(.notFound)
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(Room(home: home!.name, name: room!.name))
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
}
