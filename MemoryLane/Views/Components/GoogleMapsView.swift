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
    
    // Create and return a `GMSMapView` instance
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.delegate = context.coordinator
        
        // Perform geocoding for the given address
        updateMapView(mapView)
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update the map view when the address changes
        updateMapView(uiView)
    }
    
    func updateMapView(_ mapView: GMSMapView) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let location = placemarks?.first?.location {
                // Clear existing markers
                mapView.clear()
                
                // Convert address to coordinates and add a marker to the map
                let marker = GMSMarker()
                marker.position = location.coordinate
                marker.map = mapView
                
                // Focus the map on the marker's position
                let cameraUpdate = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 12.0))
                mapView.moveCamera(cameraUpdate)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
    }
}
