//
//  MemoryLaneApp.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import SwiftUI
import Firebase
import GoogleMaps


@main
struct MemoryLaneApp: App {
    
    @StateObject private var userViewModel = UserViewModel()
    
    
    init(){
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyBodVllpWkN93TW6NefjyNAPIKhqfTPOP0")

    }
    
    var body: some Scene {
        WindowGroup {
            // Check if the user is logged in
            if userViewModel.userIsLoggedIn {
                // Display the HomeView if the user is logged in
                TabsView()
                    .environmentObject(userViewModel)
            } else {
                // Display the LoginView if the user is not logged in
                LoginView()
                    .environmentObject(userViewModel)
            }
        }
    }
}


