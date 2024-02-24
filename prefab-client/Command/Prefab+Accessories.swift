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
                Returns an accessory from HomeKit.
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


extension Prefab {
    struct UpdateAccessory: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "update-accessory",
            abstract: "Update the characteristic of an accessory from a room in your home.",
            usage: """
                prefab update-accessory
                """,
            discussion: """
                Update the characteristic of an accessory from a room in your home.
                """)
            @Option(name: .shortAndLong, help: "The name of the home you would like accessories for.")
            var home: String
        
            @Option(name: .shortAndLong, help: "The name of the room you would like accessories for.")
            var room: String
        
            @Option(name: .shortAndLong, help: "The name of the accessory you would like to update.")
            var accessory: String
        
            @Option(name: .shortAndLong, help: "The id of the service you would like to update.")
            var serviceId: String
        
            @Option(name: .shortAndLong, help: "The id of the characteristic you would like to update.")
            var characteristicId: String
        
            @Option(name: .shortAndLong, help: "The value of the characteristic you would like to update.")
            var value: String

//        0D84EB02-914A-5B90-BF23-EF27764F9438 B16D61DB-EFC7-5BA3-BBF0-101860D06D60
        mutating func run() async {
            do{
                let accData = try await client.updateAccessory(name: accessory, home: home, room: room, serviceId: serviceId, characteristicId: characteristicId, value: value)
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
