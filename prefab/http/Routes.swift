//
//  Routes.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation
import HomeKit
import Hummingbird
import OSLog

extension Server {
    func getHomes(_ request: HBRequest) throws -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(homeBase.homes.map{Home(name: $0.name)})
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json ?? "[]"
    }
    
    func getHome(_ request: HBRequest) throws -> String {
        guard let homeName = request.parameters["home"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        let home = homeBase.homes.first(where: {$0.name == homeName.removingPercentEncoding})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(Home(name: home!.name))
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    func getRooms(_ request: HBRequest) throws -> String {
        guard let homeName = request.parameters["home"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
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
        guard let homeName = request.parameters["home"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        guard let roomName = request.parameters["room"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
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
    
    func getAccessories(_ request: HBRequest) throws -> String {
        guard let homeName = request.parameters["home"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        guard let roomName = request.parameters["room"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        let home = homeBase.homes.first(where: {$0.name == homeName.removingPercentEncoding})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let room = home?.rooms.first(where: {$0.name == roomName.removingPercentEncoding})
        if (room == nil) {
            throw HBHTTPError(.notFound)
        }
        
        let accessories = room?.accessories.map{ (hmAccessory: HMAccessory) -> Accessory in Accessory(home: home!.name, room: room!.name, name: hmAccessory.name)}
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(accessories)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    
    func getAccessory(_ request: HBRequest) throws -> String {
        guard let homeName = request.parameters["home"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        guard let roomName = request.parameters["room"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        guard let accessoryName = request.parameters["accessory"] else {
            throw HBHTTPError(
                .badRequest,
                message: "Invalid name parameter."
            )
        }
        let home = homeBase.homes.first(where: {$0.name == homeName.removingPercentEncoding})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let room = home?.rooms.first(where: {$0.name == roomName.removingPercentEncoding})
        if (room == nil) {
            throw HBHTTPError(.notFound)
        }
        let hkAccessory = room?.accessories.first(where: { (hmAccessory: HMAccessory) -> Bool in hmAccessory.name == accessoryName.removingPercentEncoding})
        if (hkAccessory == nil) {
            throw HBHTTPError(.notFound)
        }
        
        let group = DispatchGroup()
        for service in hkAccessory!.services {
            for char in service.characteristics {
                group.enter()
                // Error handling for read
                char.readValue{ (error: Error?) -> Void in group.leave() }
            }
        }
        group.wait()

        let accessory: Accessory = Accessory(
            home: home!.name,  room: room!.name, name: hkAccessory!.name, category: hkAccessory!.category.categoryType, isReachable: hkAccessory!.isReachable, supportsIdentify: hkAccessory!.supportsIdentify, isBridged: hkAccessory!.isBridged, services: hkAccessory!.services.map{ (service: HMService) -> Service in Service(name: service.name, type: service.serviceType, isPrimary: service.isPrimaryService, isUserInteractive: service.isUserInteractive, associatedType: service.associatedServiceType, characteristics: service.characteristics.map{ (char: HMCharacteristic) -> Characteristic in Characteristic(description: char.localizedDescription, properties: char.properties, type: char.characteristicType, value: "\(char.value ?? "")" ) }) }, firmwareVersion: hkAccessory!.firmwareVersion, manufacturer: hkAccessory!.manufacturer, model: hkAccessory!.model )
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(accessory)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
}
