//
//  Routes+Accessories.swift
//  Prefab
//
//  Created by kelly on 2/25/24.
//

import Foundation
import HomeKit
import Hummingbird
import OSLog

extension Server {
    func getAccessories(_ request: HBRequest) throws -> String {
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
        
        let accessories = room?.accessories.map{ (hmAccessory: HMAccessory) -> Accessory in 
            Accessory(home: home!.name, room: room!.name, name: hmAccessory.name, category: hmAccessory.category.localizedDescription)
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(accessories)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    
    func getAccessory(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        let roomName = try getRequiredParam(param: "room", request: request)
        let accessoryName = try getRequiredParam(param: "accessory", request: request)

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

        let accessory = Accessory(
            home: home!.name,  room: room!.name, name: hkAccessory!.name, category: hkAccessory!.category.localizedDescription, isReachable: hkAccessory!.isReachable, supportsIdentify: hkAccessory!.supportsIdentify, isBridged: hkAccessory!.isBridged, services: hkAccessory!.services.map{ (service: HMService) -> Service in Service(uniqueIdentifier: service.uniqueIdentifier, name: service.name, typeName: getHAPServiceInfo(fromUUIDString: service.serviceType)?.name ?? "", type: service.serviceType, isPrimary: service.isPrimaryService, isUserInteractive: service.isUserInteractive, associatedType: service.associatedServiceType, characteristics: service.characteristics.map{ (char: HMCharacteristic) -> Characteristic in Characteristic(uniqueIdentifier: char.uniqueIdentifier,  description: char.localizedDescription, properties: char.properties, typeName: getHAPCharacteristicInfo(fromUUIDString: char.characteristicType)?.name ?? "", type: char.characteristicType, metadata: CharacteristicMetadata(manufacturerDescription: char.metadata?.manufacturerDescription, validValues: char.metadata?.validValues?.map{ (number: NSNumber) -> String in return number.stringValue}, minimumValue: char.metadata?.minimumValue?.stringValue, maximumValue: char.metadata?.maximumValue?.stringValue, stepValue: char.metadata?.stepValue?.stringValue, maxLength: char.metadata?.maxLength?.stringValue, format: char.metadata?.format, units: char.metadata?.units), value: "\(char.value ?? "")" )}) }, firmwareVersion: hkAccessory!.firmwareVersion, manufacturer: hkAccessory!.manufacturer, model: hkAccessory!.model )
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(accessory)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
    
    func updateAccessory(_ request: HBRequest) throws -> String {
        let logger = Logger(subsystem: "app.prefab", category: "updateAccessory")
        logger.debug("updateAccessory called")

        // Ensure request body exists to avoid force-unwrapping crashes
        guard let bodyBuffer = request.body.buffer else {
            logger.error("Request body is missing.")
            throw HBHTTPError(.badRequest, message: "Missing request body.")
        }

        // Log raw request body for debugging
        if let rawJSON = bodyBuffer.getString(at: bodyBuffer.readerIndex, length: bodyBuffer.readableBytes) {
            logger.debug("Raw request body: \(rawJSON, privacy: .public)")
        } else {
            logger.debug("Raw request body could not be decoded as UTF-8. Byte count: \(bodyBuffer.readableBytes, privacy: .public)")
        }

        // Decode input
        let updateAccessoryInput: UpdateAccessoryInput
        do {
            updateAccessoryInput = try JSONDecoder().decode(UpdateAccessoryInput.self, from: bodyBuffer)
            logger.debug("Decoded UpdateAccessoryInput: serviceId=\(updateAccessoryInput.serviceId, privacy: .public), characteristicId=\(updateAccessoryInput.characteristicId, privacy: .public), value=\(updateAccessoryInput.value, privacy: .public)")
        } catch {
            logger.error("Failed to decode UpdateAccessoryInput: \(error.localizedDescription, privacy: .public)")
            throw HBHTTPError(.badRequest, message: "Invalid update object.")
        }

        // Extract params
        let homeName = try getRequiredParam(param: "home", request: request)
        let roomName = try getRequiredParam(param: "room", request: request)
        let accessoryName = try getRequiredParam(param: "accessory", request: request)
        logger.debug("Params home=\(homeName, privacy: .public), room=\(roomName, privacy: .public), accessory=\(accessoryName, privacy: .public)")

        // Locate Home
        let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding })
        guard let home else {
            logger.error("Home not found: \(homeName, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        logger.debug("Found home: \(home.name, privacy: .public)")

        // Locate Room
        let room = home.rooms.first(where: { $0.name == roomName.removingPercentEncoding })
        guard let room else {
            logger.error("Room not found: \(roomName, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        logger.debug("Found room: \(room.name, privacy: .public)")

        // Locate Accessory
        let hkAccessory = room.accessories.first(where: { $0.name == accessoryName.removingPercentEncoding })
        guard let hkAccessory else {
            logger.error("Accessory not found: \(accessoryName, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        logger.debug("Found accessory: \(hkAccessory.name, privacy: .public) reachable=\(hkAccessory.isReachable, privacy: .public)")

        // Locate Service
        let hkService = hkAccessory.services.first(where: { $0.uniqueIdentifier.uuidString == updateAccessoryInput.serviceId })
        guard let hkService else {
            logger.error("Service not found: \(updateAccessoryInput.serviceId, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        logger.debug("Found service: \(hkService.name, privacy: .public) type=\(hkService.serviceType, privacy: .public)")

        // Locate Characteristic
        let hkChar = hkService.characteristics.first(where: { $0.uniqueIdentifier.uuidString == updateAccessoryInput.characteristicId })
        guard let hkChar else {
            logger.error("Characteristic not found: \(updateAccessoryInput.characteristicId, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        logger.debug("Found characteristic: \(hkChar.localizedDescription, privacy: .public) type=\(hkChar.characteristicType, privacy: .public) format=\(hkChar.metadata?.format ?? "nil", privacy: .public) properties=\(hkChar.properties.joined(separator: ","), privacy: .public)")

        // Prepare value for write
        let valueToWrite: Any
        do {
            valueToWrite = try GetValue(value: updateAccessoryInput.value, format: hkChar.metadata?.format ?? "")
            logger.debug("Prepared value to write: \(String(describing: valueToWrite), privacy: .public)")
        } catch {
            logger.error("Failed to convert value '\(updateAccessoryInput.value, privacy: .public)' with format '\(hkChar.metadata?.format ?? "nil", privacy: .public)': \(error.localizedDescription, privacy: .public)")
            throw error
        }

        logger.debug("Attempting write to characteristic \(hkChar.uniqueIdentifier.uuidString, privacy: .public)")

        let group = DispatchGroup()
        group.enter()
        hkChar.writeValue(valueToWrite) { error in
            if let error {
                logger.error("writeValue completion with error: \(error.localizedDescription, privacy: .public)")
            } else {
                logger.debug("writeValue completed successfully.")
            }
            group.leave()
        }

        group.wait()
        logger.debug("writeValue wait completed.")

        return ""
    }
}

