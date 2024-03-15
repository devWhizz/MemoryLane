//
//  GoogleMapViewWithControls.swift
//  MemoryLane
//
//  Created by martin on 22.02.24.
//

import SwiftUI
import GoogleMaps


struct GoogleMapViewWithControls: View {
    
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    var address: String
    
    @State private var mapType: GMSMapViewType = .normal
    @State private var zoomLevel: Float = 10
    @State private var shouldUpdateView = false
    
    var body: some View {
        ZStack (alignment: .top) {
            // GoogleMapView with associated controls
            GoogleMapView(address: address, mapType: $mapType, zoomLevel: $zoomLevel, shouldUpdateView: $shouldUpdateView)
                .frame(height: 350)
            // Controls for the map (change map type, zoom in/out)
            MapControlsView(mapType: $mapType, zoomLevel: $zoomLevel, shouldUpdateView: $shouldUpdateView)
                .padding(.horizontal, 16)
                .padding(.top, 16)
        }
        .onReceive(memoryViewModel.objectWillChange) { _ in
            // Update the map view when memoryViewModel changes
            shouldUpdateView.toggle()
        }
    }
}
