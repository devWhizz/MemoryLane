//
//  GoogleMapsView.swift
//  MemoryVerse
//
//  Created by syntax on 23.01.24.
//


import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapView: UIViewRepresentable {
    
    // The address for the marker
    let address: String
    
    // Creates and returns a `GMSMapView` instance
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.delegate = context.coordinator
        
        // Perform geocoding for the given address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let location = placemarks?.first?.location {
                // Convert address to coordinates and add a marker to the map
                let marker = GMSMarker()
                marker.position = location.coordinate
                marker.map = mapView
                // Focus the map on the marker's position
                let cameraUpdate = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 8.0))
                mapView.moveCamera(cameraUpdate)

            }
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Aktualisiere die Ansicht bei Bedarf
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

struct GoogleMapView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleMapView(address: "Berlin, Germany")
    }
}
