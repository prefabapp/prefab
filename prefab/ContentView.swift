//
//  ContentView.swift
//  prefab
//
//  Created by Kelly Plummer on 2/14/24.
//

import SwiftUI
import HomeKit

extension HMHome: Identifiable {}

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
            
            List(homebase.homeManager.homes) { home in
                DetailView(isPrimary: home.isPrimary, name: home.name, id: home.uniqueIdentifier.uuidString)
            }.listStyle(.insetGrouped)
        }
    }
}

struct DetailView: View {
    @State var isPrimary: Bool
    @State var name: String
    @State var id: String
    
    var body: some View {
        HStack {
            Image(systemName: "house.circle").resizable()
                .frame(width: 32.0, height: 32.0)
                .clipped()
            VStack(alignment: .leading) {
                Text($name.wrappedValue)
                Text($id.wrappedValue).foregroundStyle(.secondary)
                Toggle(isOn: ($isPrimary)) {
                        Text("Primary").foregroundStyle(.secondary)
                }.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
        }
    }
}
//Struct

//#Preview {
//    ContentView()
//}
