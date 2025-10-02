//
//  LocationSearchViewModel.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation
import MapKit
import Observation

@Observable
class LocationSearchViewModel {
    var searchText: String = ""
    var searchResults: [MKMapItem] = []
    var selectedLocation: MKMapItem?
    var isSearching: Bool = false
    
    func searchLocations() async {
        guard !searchText.isEmpty else {
            await MainActor.run {
                self.searchResults = []
            }
            
            return
        }
        
        await MainActor.run {
            self.isSearching = true
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.pointOfInterest, .address]
        
        // 한국 지역으로 제한
        let center = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // 서울 중심
        let span = MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        request.region = MKCoordinateRegion(center: center, span: span)
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            await MainActor.run {
                self.searchResults = response.mapItems
                self.isSearching = false
            }
        } catch {
            print("검색 실패: \(error.localizedDescription)")
            
            await MainActor.run {
                self.searchResults = []
                self.isSearching = false
            }
        }
    }
    
    func getSelectedMatchLocation() -> MatchLocation? {
        guard let selected = selectedLocation else { return nil }
        
        let name = selected.name ?? "위치 없음"
        let address: String = {
            if let address = selected.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false) {
                return address
            }
            
            return "주소 정보 없음"
        }()
        let coordinates = Coordinates(
            latitude: selected.location.coordinate.latitude,
            longitude: selected.location.coordinate.longitude
        )
        
        return MatchLocation(
            name: name,
            address: address,
            coordinates: coordinates
        )
    }
    
    func reset() {
        searchText = ""
        searchResults = []
        selectedLocation = nil
        isSearching = false
    }
}
