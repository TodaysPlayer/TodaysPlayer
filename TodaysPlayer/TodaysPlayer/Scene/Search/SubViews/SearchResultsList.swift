//
//  SearchResultsList.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import SwiftUI
import MapKit

struct SearchResultsList: View {
    let searchText: String
    let searchResults: [MKMapItem]
    @Binding var selectedLocation: MKMapItem?
    
    var body: some View {
        Group {
            if searchResults.isEmpty {
                // 검색 결과 없음
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    
                    Text(searchText.isEmpty ? "장소를 검색해주세요" : "검색 결과가 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            } else {
                // 검색 결과 리스트
                ScrollView {
                    VStack(spacing: 0) {
                        // 검색 결과 아이템들
                        ForEach(searchResults, id: \.self) { mapItem in
                            // 리스트 아이템
                            LocationListItem(
                                mapItem: mapItem,
                                isSelected: selectedLocation == mapItem,
                                onTap: {
                                    // 애니메이션 없이 즉시 변경
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        selectedLocation = mapItem
                                    }
                                }
                            )
                            
                            // 선택된 아이템 바로 밑에 지도 표시
                            if selectedLocation == mapItem {
                                VStack(spacing: 0) {
                                    Divider()
                                        .padding(.vertical, 12)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("선택한 위치")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.primary)
                                            .padding(.horizontal, 16)
                                        
                                        // 작은 지도
                                        MapPreview(mapItem: mapItem)
                                    }
                                    .padding(.bottom, 12)
                                    
                                    Divider()
                                }
                            } else if mapItem != searchResults.last {
                                Divider()
                                    .padding(.leading, 52)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .animation(nil, value: selectedLocation)
                }
            }
        }
    }
}
