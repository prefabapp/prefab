//
//  Client+Accessories.swift
//  prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation
import ArgumentParser

extension Prefab {
    struct GetAccessories: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "get-accessories",
            abstract: "Retrieve a list of the accessories from a room in your home.",
            usage: """
                prefab get-accessories
                """,
            discussion: """
                Returns an array of your accessories from HomeKit.
                """)
            @Option(name: .shortAndLong, help: "The name of the home you would like accessories for.")
            var home: String
        
            @Option(name: .shortAndLong, help: "The name of the room you would like accessories for.")
            var room: String
        
        mutating func run() async {
            do{
                let accessories = try await client.getAccessories(home: home, room: room)
                print(accessories)
            } catch UninitializeClientError.propertyIsNotSet(let property) {
                print("Attempting to use client without setting \(property)")
            } catch HTTPResponseError.notFound(let response), HTTPResponseError.tooManyRequests(let response), HTTPResponseError.forbidden(let response) {
                print("\(response)")
            } catch HTTPResponseError.unexpected(let response, let code) {
                print("\(response), \(code)")
            } catch {
                print("An unknown error occured: \(error)")
            }
        }
    }
}

extension Prefab {
    struct GetAccessory: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "get-accessory",
            abstract: "Retrieve an accessory from a room in your home.",
            usage: """
                prefab get-accessory
                """,
            discussion: """
                Returns an accessories from HomeKit.
                """)
            @Option(name: .shortAndLong, help: "The name of the home you would like accessories for.")
            var home: String
        
            @Option(name: .shortAndLong, help: "The name of the room you would like accessories for.")
            var room: String
        
            @Option(name: .shortAndLong, help: "The name of the accessory you would like to see.")
            var accessory: String
        
        mutating func run() async {
            do{
                let accData = try await client.getAccessory(name: accessory, home: home, room: room)
                print(accData)
            } catch UninitializeClientError.propertyIsNotSet(let property) {
                print("Attempting to use client without setting \(property)")
            } catch HTTPResponseError.notFound(let response), HTTPResponseError.tooManyRequests(let response), HTTPResponseError.forbidden(let response) {
                print("\(response)")
            } catch HTTPResponseError.unexpected(let response, let code) {
                print("\(response), \(code)")
            } catch {
                print("An unknown error occured: \(error)")
            }
        }
    }
}
