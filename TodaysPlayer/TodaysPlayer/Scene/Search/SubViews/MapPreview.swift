//
//  MapPreview.swift
//  TodaysPlayer
//
//  Created by AI on 10/1/25.
//

import SwiftUI
import MapKit

struct MapPreview: View {
    let mapItem: MKMapItem
    @State private var region: MKCoordinateRegion
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        let coordinate = mapItem.location.coordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Map(position: .constant(.region(region))) {
            Marker(mapItem.name ?? "선택한 위치", coordinate: mapItem.location.coordinate)
        }
        .frame(height: 200)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}
