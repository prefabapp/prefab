//
//  Routes+Scenes.swift
//  PrefabServer
//
//  Scene routes
//

import Foundation
import HomeKit
import Hummingbird
import OSLog

extension Server {
    
    /// GET /scenes/:home - List all scenes in a home
    func getScenes(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        
        guard let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding }) else {
            throw HBHTTPError(.notFound)
        }
        
        let scenes = home.actionSets.map { actionSet in
            HomeKitScene(
                home: home.name,
                uniqueIdentifier: actionSet.uniqueIdentifier,
                name: actionSet.name,
                isBuiltIn: actionSet.actionSetType != HMActionSetTypeUserDefined
            )
        }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(scenes)
        let json = String(data: jsonData, encoding: .utf8)
        
        return json!
    }
    
    /// GET /scenes/:home/:scene - Get detailed scene info
    func getScene(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        let sceneId = try getRequiredParam(param: "scene", request: request)
        
        guard let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding }) else {
            throw HBHTTPError(.notFound)
        }
        
        guard let sceneUUID = UUID(uuidString: sceneId),
              let actionSet = home.actionSets.first(where: { $0.uniqueIdentifier == sceneUUID }) else {
            throw HBHTTPError(.notFound)
        }
        
        let actions = actionSet.actions.compactMap { action -> SceneAction? in
            guard let charAction = action as? HMCharacteristicWriteAction<NSCopying> else {
                return nil
            }
            return SceneAction(
                accessoryName: charAction.characteristic.service?.accessory?.name ?? "",
                serviceName: charAction.characteristic.service?.name ?? "",
                characteristicType: charAction.characteristic.characteristicType,
                targetValue: "\(charAction.targetValue)"
            )
        }
        
        let sceneDetail = SceneDetail(
            home: home.name,
            uniqueIdentifier: actionSet.uniqueIdentifier,
            name: actionSet.name,
            isBuiltIn: actionSet.actionSetType != HMActionSetTypeUserDefined,
            actions: actions
        )
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(sceneDetail)
        let json = String(data: jsonData, encoding: .utf8)
        
        return json!
    }
    
    /// POST /scenes/:home/:scene/execute - Execute a scene
    func executeScene(_ request: HBRequest) throws -> String {
        let logger = Logger(subsystem: "app.prefab", category: "executeScene")
        let homeName = try getRequiredParam(param: "home", request: request)
        let sceneId = try getRequiredParam(param: "scene", request: request)
        
        guard let home = homeBase.homes.first(where: { $0.name == homeName.removingPercentEncoding }) else {
            logger.error("Home not found: \(homeName, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        
        guard let sceneUUID = UUID(uuidString: sceneId),
              let actionSet = home.actionSets.first(where: { $0.uniqueIdentifier == sceneUUID }) else {
            logger.error("Scene not found: \(sceneId, privacy: .public)")
            throw HBHTTPError(.notFound)
        }
        
        logger.debug("Executing scene: \(actionSet.name, privacy: .public)")
        
        var executeError: Error?
        let group = DispatchGroup()
        group.enter()
        home.executeActionSet(actionSet) { error in
            if let error = error {
                logger.error("Scene execution failed: \(error.localizedDescription, privacy: .public)")
                executeError = error
            } else {
                logger.debug("Scene executed successfully")
            }
            group.leave()
        }
        group.wait()
        
        if let error = executeError {
            throw HBHTTPError(.internalServerError, message: error.localizedDescription)
        }
        
        let response = ["success": true, "scene": actionSet.name] as [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject: response)
        return String(data: jsonData, encoding: .utf8)!
    }
}

