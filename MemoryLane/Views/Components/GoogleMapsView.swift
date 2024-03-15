//
//  GoogleMapsView.swift
//  MemoryLane
//
//  Created by martin on 31.01.24.
//

import SwiftUI
import GoogleMaps
import CoreLocation


struct GoogleMapView: UIViewRepresentable {
    
    // Address for the marker
    var address: String
    
    @Binding var mapType: GMSMapViewType
    @Binding var zoomLevel: Float
    @Binding var shouldUpdateView: Bool
    
    // Create and return a `GMSMapView` instance
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.mapType = mapType
        mapView.delegate = context.coordinator
        
        // Perform geocoding for the given address initially
        updateMapView(mapView)
        
        return mapView
    }
    
    // Call func when view needs to be updated
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update the map view when soemthing changes
        if shouldUpdateView {
            // Asynchronous update on the main thread to avoid state modification during view update
            DispatchQueue.main.async {
                updateMapView(uiView)
                // Reset the update flag after the view has been updated
                shouldUpdateView = false
            }
        }
    }
    
    // Update the Google Maps view with the given address
    func updateMapView(_ mapView: GMSMapView) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let location = placemarks?.first?.location {
                // Clear existing markers on the map
                mapView.clear()
                
                // Convert address to coordinates and add a marker to the map
                let marker = GMSMarker()
                marker.position = location.coordinate
                mapView.mapType = mapType
                marker.map = mapView
                
                // Focus the map on the marker's position
                let cameraUpdate = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(
                    withLatitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    zoom: zoomLevel
                ))
                mapView.moveCamera(cameraUpdate)
            }
        }
    }
    
    // Create and return the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class to handle delegate functions
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
    }
}
