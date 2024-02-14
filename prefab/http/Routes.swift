//
//  Routes.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation
import Hummingbird

extension Server {
    func getHomes(_ request: HBRequest) throws -> String {
        
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(homeStore.homes.map{Home(name: $0.name)})
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            
            return json ?? "[]"
        
    }
    
    func getHome(_ request: HBRequest) throws -> String {
        let homeName = request.parameters["home"]!
        let home = homeStore.homes.first(where: {$0.name == homeName})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(Home(name: home!.name))
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    func getRooms(_ request: HBRequest) throws -> String {
        let homeName = request.parameters["home"]!
        let home = homeStore.homes.first(where: {$0.name == homeName})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let rooms = home?.rooms.map{Room(home: home!.name, name: $0.name)}
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(rooms)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    func getRoom(_ request: HBRequest) throws -> String
    {
        let homeName = request.parameters["home"]!
        let roomName = request.parameters["room"]!
        let home = homeStore.homes.first(where: {$0.name == homeName})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let room = home?.rooms.first(where: {$0.name == roomName})
        if (room == nil) {
            throw HBHTTPError(.notFound)
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(Room(home: home!.name, name: room!.name))
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
}
