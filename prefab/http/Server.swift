//
//  Server.swift
//  rikerd
//
//  Created by Kelly Plummer on 2/14/24.
//

import Foundation
import OSLog
import Hummingbird

class Server  {
    var homeStore: HomeStore
    init() {
        homeStore = HomeStore()
        let serverTread = Thread.init(target: self, selector: #selector(startServer), object: HomeStore())
        serverTread.start()
    }
    
    @objc
    func startServer(homeStore: HomeStore) {
        Task{
            let app = HBApplication(configuration: .init(address: .hostname("127.0.0.1", port: 8080)))
            app.router.get("homes", use: self.getHomes) 
            app.router.get("homes/:home", use: self.getHome)
           
            app.router.get("rooms/:home", use: self.getRooms)
            app.router.get("rooms/:home/:room", use: self.getRoom)
            
            
            try app.start()
            await app.asyncWait()
        }
    }
}
