//
//  Prefab+Rooms.swift
//  prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation
import ArgumentParser

extension Prefab {
    struct GetRooms: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "get-rooms",
            abstract: "Retrieve a list of the rooms in your home.",
            usage: """
                prefab get-homes
                """,
            discussion: """
                Returns an array of your homes from HomeKit.
                """)
            @Option(name: .shortAndLong, help: "The name of the home you would like rooms for." )
            var home: String
        
        mutating func run() async {
            do{
                let rooms = try await client.getRooms(home: home)
                print(rooms)
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
    struct GetRoom: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "get-room",
            abstract: "Retrieve a home.",
            usage: """
                prefab get-home
                """,
            discussion: """
                Returns an array of your homes from HomeKit.
                """)
        @Option(name: .shortAndLong, help: "The name of the home you would like rooms for.")
        var home: String
        
        @Option(name: .shortAndLong, help: "The name of the room you would like to see.")
        var room: String
        
        mutating func run() async {
            do{
                let home = try await client.getRoom(name: room, home: home)
                print(home)
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
