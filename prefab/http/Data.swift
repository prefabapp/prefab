//
//  Data.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation

struct Home: Encodable, Decodable {
    var name: String
}

struct Room: Encodable, Decodable {
    var home: String
    var name: String
}

struct Accessory: Encodable, Decodable {
    var home: String
    var room: String
    var name: String
    
    var category: String?
    var isReachable: Bool?
    var supportsIdentify: Bool?
    var isBridged: Bool?

    var services: [Service]?
    
    var firmwareVersion: String?
    var manufacturer: String?
    var model: String?
}

struct Service: Encodable, Decodable {
    var uniqueIdentifier: UUID
    var name: String
    var type: String
    var isPrimary: Bool
    var isUserInteractive: Bool
    var associatedType: String?
    
    var characteristics: [Characteristic]
}

struct Characteristic: Encodable, Decodable {
    var uniqueIdentifier: UUID
    var description: String
    var properties: [String]
    var type: String
    var metadata: CharacteristicMetadata?
    var value: String?
}

struct CharacteristicMetadata: Encodable, Decodable {
    init(manufacturerDescription: String? = nil, validValues: [String]? = nil, minimumValue: String? = nil, maximumValue: String? = nil, stepValue: String? = nil, maxLength: String? = nil, format: String? = nil, units: String? = nil) {
        self.manufacturerDescription = manufacturerDescription
        self.validValues = validValues
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.stepValue = stepValue
        self.maxLength = maxLength
        self.format = format
        self.units = units
    }
    var manufacturerDescription: String?
    var validValues: [String]?
    var minimumValue: (String)?
    var maximumValue: (String)?
    var stepValue: (String)?
    var maxLength: (String)?
    var format: String?
    var units: String?
}

struct UpdateAccessoryInput: Encodable, Decodable {
    var home: String
    var room: String
    var accessory: String
    var serviceId: String
    var characteristicId: String
    var value: String
}
