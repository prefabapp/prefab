//
//  Data.swift
//  PrefabServer
//
//  Data models for API responses
//

import Foundation

public struct Home: Encodable, Decodable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct Room: Encodable, Decodable {
    public var home: String
    public var name: String
    
    public init(home: String, name: String) {
        self.home = home
        self.name = name
    }
}

public struct Accessory: Encodable, Decodable {
    public var home: String
    public var room: String
    public var name: String
    
    public var category: String?
    public var isReachable: Bool?
    public var supportsIdentify: Bool?
    public var isBridged: Bool?

    public var services: [Service]?
    
    public var firmwareVersion: String?
    public var manufacturer: String?
    public var model: String?
    
    public init(home: String, room: String, name: String, category: String? = nil, isReachable: Bool? = nil, supportsIdentify: Bool? = nil, isBridged: Bool? = nil, services: [Service]? = nil, firmwareVersion: String? = nil, manufacturer: String? = nil, model: String? = nil) {
        self.home = home
        self.room = room
        self.name = name
        self.category = category
        self.isReachable = isReachable
        self.supportsIdentify = supportsIdentify
        self.isBridged = isBridged
        self.services = services
        self.firmwareVersion = firmwareVersion
        self.manufacturer = manufacturer
        self.model = model
    }
}

public struct Service: Encodable, Decodable {
    public var uniqueIdentifier: UUID
    public var name: String
    public var typeName: String
    public var type: String
    public var isPrimary: Bool
    public var isUserInteractive: Bool
    public var associatedType: String?
    
    public var characteristics: [Characteristic]
    
    public init(uniqueIdentifier: UUID, name: String, typeName: String, type: String, isPrimary: Bool, isUserInteractive: Bool, associatedType: String? = nil, characteristics: [Characteristic]) {
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.typeName = typeName
        self.type = type
        self.isPrimary = isPrimary
        self.isUserInteractive = isUserInteractive
        self.associatedType = associatedType
        self.characteristics = characteristics
    }
}

public struct Characteristic: Encodable, Decodable {
    public var uniqueIdentifier: UUID
    public var description: String
    public var properties: [String]
    public var typeName: String
    public var type: String
    public var metadata: CharacteristicMetadata?
    public var value: String?
    
    public init(uniqueIdentifier: UUID, description: String, properties: [String], typeName: String, type: String, metadata: CharacteristicMetadata? = nil, value: String? = nil) {
        self.uniqueIdentifier = uniqueIdentifier
        self.description = description
        self.properties = properties
        self.typeName = typeName
        self.type = type
        self.metadata = metadata
        self.value = value
    }
}

public struct CharacteristicMetadata: Encodable, Decodable {
    public init(manufacturerDescription: String? = nil, validValues: [String]? = nil, minimumValue: String? = nil, maximumValue: String? = nil, stepValue: String? = nil, maxLength: String? = nil, format: String? = nil, units: String? = nil) {
        self.manufacturerDescription = manufacturerDescription
        self.validValues = validValues
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.stepValue = stepValue
        self.maxLength = maxLength
        self.format = format
        self.units = units
    }
    public var manufacturerDescription: String?
    public var validValues: [String]?
    public var minimumValue: (String)?
    public var maximumValue: (String)?
    public var stepValue: (String)?
    public var maxLength: (String)?
    public var format: String?
    public var units: String?
}

public struct UpdateAccessoryInput: Encodable, Decodable {
    public var serviceId: String
    public var characteristicId: String
    public var value: String
    
    public init(serviceId: String, characteristicId: String, value: String) {
        self.serviceId = serviceId
        self.characteristicId = characteristicId
        self.value = value
    }
}

enum UnknownFormatError : Error {
    case formatValue(format: String)
}

func GetValue(value: String, format: String) throws -> Any {
    switch format {
    case "bool":
        let trues: [String] = ["1", "true", "on"]
        return trues.contains(where: { $0.lowercased() == value.lowercased() } )
    default:
        throw UnknownFormatError.formatValue(format: format)
    }
}

// MARK: - Scenes

/// Basic scene info (list view)
public struct HomeKitScene: Encodable, Decodable {
    public var home: String
    public var uniqueIdentifier: UUID
    public var name: String
    public var isBuiltIn: Bool
    
    public init(home: String, uniqueIdentifier: UUID, name: String, isBuiltIn: Bool) {
        self.home = home
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.isBuiltIn = isBuiltIn
    }
}

/// Action within a scene
public struct SceneAction: Encodable, Decodable {
    public var accessoryName: String
    public var serviceName: String
    public var characteristicType: String
    public var targetValue: String
    
    public init(accessoryName: String, serviceName: String, characteristicType: String, targetValue: String) {
        self.accessoryName = accessoryName
        self.serviceName = serviceName
        self.characteristicType = characteristicType
        self.targetValue = targetValue
    }
}

/// Detailed scene info including actions
public struct SceneDetail: Encodable, Decodable {
    public var home: String
    public var uniqueIdentifier: UUID
    public var name: String
    public var isBuiltIn: Bool
    public var actions: [SceneAction]
    
    public init(home: String, uniqueIdentifier: UUID, name: String, isBuiltIn: Bool, actions: [SceneAction]) {
        self.home = home
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.isBuiltIn = isBuiltIn
        self.actions = actions
    }
}

// MARK: - Accessory Groups

/// Service within a group
public struct GroupService: Encodable, Decodable {
    public var accessoryName: String
    public var serviceName: String
    public var serviceType: String
    public var uniqueIdentifier: UUID
    
    public init(accessoryName: String, serviceName: String, serviceType: String, uniqueIdentifier: UUID) {
        self.accessoryName = accessoryName
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.uniqueIdentifier = uniqueIdentifier
    }
}

/// Basic group info (list view)
public struct AccessoryGroup: Encodable, Decodable {
    public var home: String
    public var uniqueIdentifier: UUID
    public var name: String
    public var serviceCount: Int
    
    public init(home: String, uniqueIdentifier: UUID, name: String, serviceCount: Int) {
        self.home = home
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.serviceCount = serviceCount
    }
}

/// Detailed group info including services
public struct AccessoryGroupDetail: Encodable, Decodable {
    public var home: String
    public var uniqueIdentifier: UUID
    public var name: String
    public var services: [GroupService]
    
    public init(home: String, uniqueIdentifier: UUID, name: String, services: [GroupService]) {
        self.home = home
        self.uniqueIdentifier = uniqueIdentifier
        self.name = name
        self.services = services
    }
}

/// Input for updating group characteristics
public struct UpdateGroupInput: Encodable, Decodable {
    public var characteristicType: String
    public var value: String
    
    public init(characteristicType: String, value: String) {
        self.characteristicType = characteristicType
        self.value = value
    }
}

