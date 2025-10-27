//
//  SearchBar.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import SwiftUI
import MapKit

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var searchResults: [MKMapItem]
    @Binding var selectedLocation: MKMapItem?
    let isSearching: Bool
    let onSearch: () async -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 검색 입력 필드
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("구장, 주소 검색", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                        selectedLocation = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // 검색 버튼
            Button(action: {
                Task {
                    await onSearch()
                }
            }) {
                if isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("검색")
                        .fontWeight(.semibold)
                }
            }
            .disabled(searchText.isEmpty || isSearching)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(searchText.isEmpty ? Color.gray : Color.futsalGreen)
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}
