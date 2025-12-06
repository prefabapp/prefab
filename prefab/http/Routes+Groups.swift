//
//  Routes+Groups.swift
//  Prefab
//
//  Created by Copilot on 2025.
//

import Foundation
import HomeKit
import Hummingbird
import OSLog

extension Server {
    
    /// GET /groups/:home - List all accessory groups in a home
    func getGroups(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        
        guard let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding }) else {
            throw HBHTTPError(.notFound)
        }
        
        let groups = home.serviceGroups.map { serviceGroup in
            AccessoryGroup(
                home: home.name,
                uniqueIdentifier: serviceGroup.uniqueIdentifier,
                name: serviceGroup.name,
                serviceCount: serviceGroup.services.count
            )
        }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(groups)
        let json = String(data: jsonData, encoding: .utf8)
        
        return json!
    }
    
    /// GET /groups/:home/:group - Get detailed group info
    func getGroup(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        let groupId = try getRequiredParam(param: "group", request: request)
        
        guard let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding }) else {
            throw HBHTTPError(.notFound)
        }
        
        guard let groupUUID = UUID(uuidString: groupId),
              let serviceGroup = home.serviceGroups.first(where: { $0.uniqueIdentifier == groupUUID }) else {
            throw HBHTTPError(.notFound)
        }
        
        let services = serviceGroup.services.map { service in
            GroupService(
                accessoryName: service.accessory?.name ?? "",
                serviceName: service.name,
                serviceType: service.serviceType,
                uniqueIdentifier: service.uniqueIdentifier
            )
        }
        
        let groupDetail = AccessoryGroupDetail(
            home: home.name,
            uniqueIdentifier: serviceGroup.uniqueIdentifier,
            name: serviceGroup.name,
            services: services
        )
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(groupDetail)
        let json = String(data: jsonData, encoding: .utf8)
        
        return json!
    }
    
    /// PUT /groups/:home/:group - Update all accessories in a group
    func updateGroup(_ request: HBRequest) throws -> String {
        let logger = Logger(subsystem: "app.prefab", category: "updateGroup")
        
        guard let bodyBuffer = request.body.buffer else {
            logger.error("Request body is missing.")
            throw HBHTTPError(.badRequest, message: "Missing request body.")
        }
        
        let updateInput: UpdateGroupInput
        do {
            updateInput = try JSONDecoder().decode(UpdateGroupInput.self, from: bodyBuffer)
            logger.debug("Decoded UpdateGroupInput: characteristicType=\(updateInput.characteristicType, privacy: .public), value=\(updateInput.value, privacy: .public)")
        } catch {
            logger.error("Failed to decode UpdateGroupInput: \(error.localizedDescription, privacy: .public)")
            throw HBHTTPError(.badRequest, message: "Invalid update object.")
        }
        
        let homeName = try getRequiredParam(param: "home", request: request)
        let groupId = try getRequiredParam(param: "group", request: request)
        
        guard let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding }) else {
            logger.error("Home not found: \(homeName, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        
        guard let groupUUID = UUID(uuidString: groupId),
              let serviceGroup = home.serviceGroups.first(where: { $0.uniqueIdentifier == groupUUID }) else {
            logger.error("Group not found: \(groupId, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        
        logger.debug("Updating group: \(serviceGroup.name, privacy: .public) with \(serviceGroup.services.count) services")
        
        // Find all characteristics of the requested type and update them
        var successCount = 0
        var failCount = 0
        let group = DispatchGroup()
        
        for service in serviceGroup.services {
            for characteristic in service.characteristics {
                if characteristic.characteristicType == updateInput.characteristicType {
                    // Convert value based on format
                    let valueToWrite: Any
                    do {
                        valueToWrite = try GetValue(value: updateInput.value, format: characteristic.metadata?.format ?? "")
                    } catch {
                        logger.error("Failed to convert value for characteristic: \(error.localizedDescription, privacy: .public)")
                        failCount += 1
                        continue
                    }
                    
                    group.enter()
                    characteristic.writeValue(valueToWrite) { error in
                        if let error = error {
                            logger.error("Write failed for \(service.name, privacy: .public): \(error.localizedDescription, privacy: .public)")
                            failCount += 1
                        } else {
                            logger.debug("Write succeeded for \(service.name, privacy: .public)")
                            successCount += 1
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.wait()
        
        let response: [String: Any] = [
            "success": failCount == 0,
            "group": serviceGroup.name,
            "updated": successCount,
            "failed": failCount
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: response)
        return String(data: jsonData, encoding: .utf8)!
    }
}
