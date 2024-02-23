//
//  Homes.swift
//  Prefab
//
//  Created by Kelly Plummer on 2/22/24.
//

import Foundation
import ArgumentParser

extension Prefab {
    struct GetHomes: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "get-homes",
            abstract: "Retrieve a list of your homes.",
            usage: """
                prefab get-homes
                """,
            discussion: """
                Returns an array of your homes from HomeKit.
                """)
        mutating func run() async {
            do{
                let homes = try await client.getHomes()
                print(homes)
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
    struct GetHome: AsyncParsableCommand {
        @Option(name: .shortAndLong, help: "The name of the home.")
        var home: String
        
        static var configuration = CommandConfiguration(
            commandName: "get-home",
            abstract: "Retrieve a home.",
            usage: """
                prefab get-home
                """,
            discussion: """
                Returns an array of your homes from HomeKit.
                """)
        mutating func run() async {
            do{
                let homes = try await client.getHome(name: home)
                print(homes)
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
