//
//  LocationSearchBottomSheet.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import SwiftUI
import MapKit

struct LocationSearchBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedMatchLocation: MatchLocation?
    
    @State private var viewModel = LocationSearchViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 검색창
            SearchBar(
                searchText: $viewModel.searchText,
                searchResults: $viewModel.searchResults,
                selectedLocation: $viewModel.selectedLocation,
                isSearching: viewModel.isSearching,
                onSearch: {
                    await viewModel.searchLocations()
                }
            )
            
            // 검색 결과 리스트
            SearchResultsList(
                searchText: viewModel.searchText,
                searchResults: viewModel.searchResults,
                selectedLocation: $viewModel.selectedLocation
            )
            
            // 선택하기 버튼 (선택된 항목이 있을 때만)
            if viewModel.selectedLocation != nil {
                ConfirmButton {
                    if let matchLocation = viewModel.getSelectedMatchLocation() {
                        selectedMatchLocation = matchLocation
                        isPresented = false
                        viewModel.reset()
                    }
                }
            }
        }
        .navigationTitle("장소 검색")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isPresented = false
                    viewModel.reset()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    LocationSearchBottomSheet(
        isPresented: .constant(true),
        selectedMatchLocation: .constant(nil)
    )
}
