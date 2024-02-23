//
//  HomeStore.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation
import HomeKit
import OSLog


/// A container for the home manager that’s accessible throughout the app.
class HomeBase: NSObject, ObservableObject, HMHomeManagerDelegate {
    /// A singleton that can be used anywhere in the app to access the home manager.
    static var shared = HomeBase()

    @Published var homes: [HMHome] = []
    override init(){
        super.init()
        homeManager.delegate = self
    }
    
    /// The one and only home manager that belongs to the home store singleton.
    @Published var homeManager = HMHomeManager()

    /// A set of objects that want to receive accessory delegate callbacks.
    @Published var accessoryDelegates = Set<NSObject>()
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Logger().log("Manager: \(manager)")
        Logger().log("Homes: \(manager.homes)")
        homes = manager.homes
    }
}
