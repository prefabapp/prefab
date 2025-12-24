//
//  HomeBase.swift
//  PrefabServer
//
//  HomeKit manager wrapper
//

import Foundation
import Combine
import HomeKit
import OSLog


/// A container for the home manager that's accessible throughout the app.
@available(macCatalyst 14.0, *)
public class HomeBase: NSObject, ObservableObject, HMHomeManagerDelegate {
    /// A singleton that can be used anywhere in the app to access the home manager.
    public static var shared = HomeBase()

    @Published public var homes: [HMHome] = []
    
    public override init(){
        super.init()
        homeManager.delegate = self
    }
    
    /// The one and only home manager that belongs to the home store singleton.
    @Published public var homeManager = HMHomeManager()

    /// A set of objects that want to receive accessory delegate callbacks.
    @Published public var accessoryDelegates = Set<NSObject>()
    
    public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Logger().log("Manager: \(manager)")
        Logger().log("Homes: \(manager.homes)")
        homes = manager.homes
    }
    
    public func getHomes() {
        
    }
}

