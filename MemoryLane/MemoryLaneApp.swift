//
//  MemoryLaneApp.swift
//  MemoryLane
//
//  Created by martin on 22.01.24.
//

import SwiftUI
import Firebase
import GoogleMaps
import GooglePlaces


@main
struct MemoryLaneApp: App {
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var memoryViewModel = MemoryViewModel()
    
    // Set dark mode setting
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled: Bool = false
    
    
    init(){
        
        // Firebase configuration
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        // Google Maps/Places configuration
        GMSServices.provideAPIKey("AIzaSyBodVllpWkN93TW6NefjyNAPIKhqfTPOP0")
        GMSPlacesClient.provideAPIKey("AIzaSyBodVllpWkN93TW6NefjyNAPIKhqfTPOP0")
        
    }
    
    var body: some Scene {
        WindowGroup {
            // Check if the user is logged in
            if userViewModel.userIsLoggedIn {
                // Display the HomeView if the user is logged in
                TabsView()
                    .environmentObject(userViewModel)
                    .environmentObject(memoryViewModel)
                // Set the preferred color scheme based on the dark mode settings
                    .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
                    .onAppear {
                        // Read the current value for dark mode from UserDefaults
                        isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
                    }
            } else {
                // Display the LoginView if the user is not logged in
                LoginView()
                    .environmentObject(userViewModel)
                    .environmentObject(memoryViewModel)
                // Set the preferred color scheme based on the dark mode settings
                    .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
                    .onAppear {
                        // Read the current value for dark mode from UserDefaults
                        isDarkModeEnabled = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
                    }
            }
        }
    }
}
