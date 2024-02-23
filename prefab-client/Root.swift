//
//  main.swift
//  prefab-client
//
//  Created by Kelly Plummer on 2/15/24.
//

import Foundation
import ArgumentParser

@main
struct Prefab: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "prefab",
        abstract: "A tool for interacting with homes.",
        usage: """
            prefab command
            """,
        discussion: """
            Prints to stdout forever, or until you halt the program.
            """,
        subcommands: [GetHomes.self, GetHome.self, GetRooms.self, GetRoom.self, GetAccessory.self, GetAccessories.self])

    static let client: Client = Client.initShared(host: "localhost", port: "8080", scheme: "http")
    
//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false

//    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
//    var count: Int? = nil

//    @Argument(help: "The phrase to repeat.")
//    var phrase: String


}
