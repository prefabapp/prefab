//
//  ContentView.swift
//  prefab
//
//  Created by Kelly Plummer on 2/14/24.
//

import SwiftUI
import HomeKit

struct ContentView: View {
    @StateObject var homebase: HomeBase
    var body: some View {
        VStack {
            Image(systemName: "homekit")
                .resizable()
                .frame(width: 64.0, height: 64.0)
                .foregroundStyle(.tint)
                .clipped()

            Text("All your homes are belong to us!")
            
            List(homebase.homeManager.homes, id: \.uniqueIdentifier) { home in
                DetailView(isPrimary: home.isPrimary, name: home.name, id: home.uniqueIdentifier.uuidString)
            }.listStyle(.insetGrouped)
        }
    }
}

struct DetailView: View {
    let isPrimary: Bool
    let name: String
    let id: String
    
    var body: some View {
        HStack {
            Image(systemName: "house.circle").resizable()
                .frame(width: 32.0, height: 32.0)
                .clipped()
            VStack(alignment: .leading) {
                Text(name)
                Text(id).foregroundStyle(.secondary)
                Toggle(isOn: .constant(isPrimary)) {
                        Text("Primary").foregroundStyle(.secondary)
                }
                .disabled(true)
            }
        }
    }
}
//Struct

//#Preview {
//    ContentView()
//}

