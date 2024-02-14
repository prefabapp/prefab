//
//  prefabApp.swift
//  prefab
//
//  Created by Kelly Plummer on 2/14/24.
//

import SwiftUI


@main
struct prefabApp: App {
    init() {
        let _ = Server()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
