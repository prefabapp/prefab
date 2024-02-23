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
    var name: String
    var type: String
    var isPrimary: Bool
    var isUserInteractive: Bool
    var associatedType: String?
    
    var characteristics: [Characteristic]
}

struct Characteristic: Encodable, Decodable {
    var description: String
    var properties: [String]
    var type: String
    var value: String?
}
