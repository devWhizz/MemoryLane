//
//  MapControlsView.swift
//  MemoryLane
//
//  Created by martin on 22.02.24.
//

import SwiftUI
import GoogleMaps

struct MapControlsView: View {
    
    @Binding var mapType: GMSMapViewType
    @Binding var zoomLevel: Float
    @Binding var shouldUpdateView: Bool
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Button {
                    zoomLevel += 1
                    shouldUpdateView.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                }
                Button {
                    zoomLevel -= 1
                    shouldUpdateView.toggle()
                } label: {
                    Image(systemName: "minus")
                        .font(.title2)
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                }
            }
            Spacer()
            VStack {
                Button {
                    mapType = (mapType == .normal) ? .satellite : .normal
                    shouldUpdateView.toggle()
                } label: {
                    Image(systemName: "square.2.layers.3d.bottom.filled")
                        .font(.title2)
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                }
            }
        }
    }
}
