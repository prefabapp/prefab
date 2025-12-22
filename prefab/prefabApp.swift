//
//  prefabApp.swift
//  prefab
//
//  Created by Kelly Plummer on 2/14/24.
//

import SwiftUI


@main
struct prefabApp: App {
    private let server = Server()
    @State var displayInstall: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(homebase: HomeBase.shared)
                .alert("This will install the prefab tool on your PATH", isPresented: $displayInstall) {
                    Button("OK", role: .none, action: {
//                        install the tool
                    })
                    Button("Cancel", role: .cancel){}

                }
        }
        .commands {
            CommandGroup(after: CommandGroupPlacement.appSettings, addition: {
                Button(action: {
                        displayInstall = true
                    }, label: {
                        Text("Install Tool...")
                    })
            })
        }
    }
}
