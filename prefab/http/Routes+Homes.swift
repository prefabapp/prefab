//
//  Routes+Homes.swift
//  Prefab
//
//  Created by kelly on 2/25/24.
//

import Foundation
import Hummingbird

extension Server {
    func getHomes(_ request: HBRequest) throws -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(homeBase.homes.map{Home(name: $0.name)})
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json ?? "[]"
    }
    
    func getHome(_ request: HBRequest) throws -> String {
        let homeName = try getRequiredParam(param: "home", request: request)
        let home = homeBase.homes.first(where: {$0.name == homeName.removingPercentEncoding})
        if (home == nil) {
            throw HBHTTPError(.notFound)
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(Home(name: home!.name))
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        
        return json!
    }
}
