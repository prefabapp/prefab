//
//  Data.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation


struct Home: Encodable {
    var name: String
}

struct Room: Encodable {
    var home: String
    var name: String
}

struct Accessory: Encodable {
    var home: String
    var room: String
    var name: String
}
