//
//  FilterButtonsView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct FilterButtonsView: View {
    let regions: [RegionData]
    @Binding var selectedRegion: String?
    @Binding var selectedSkillLevel: String?
    let onFilterChange: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(
                    title: "전체",
                    isSelected: selectedRegion == nil && selectedSkillLevel == nil
                ) {
                    selectedRegion = nil
                    selectedSkillLevel = nil
                    onFilterChange()
                }
                
                ForEach(regions, id: \.id) { region in
                    FilterButton(
                        title: region.name,
                        isSelected: selectedRegion == region.name
                    ) {
                        selectedRegion = region.name
                        onFilterChange()
                    }
                }
                
                FilterButton(
                    title: "초급",
                    isSelected: selectedSkillLevel == "초급"
                ) {
                    selectedSkillLevel = "초급"
                    onFilterChange()
                }
                
                FilterButton(
                    title: "중급",
                    isSelected: selectedSkillLevel == "중급"
                ) {
                    selectedSkillLevel = "중급"
                    onFilterChange()
                }
                
                FilterButton(
                    title: "고급",
                    isSelected: selectedSkillLevel == "고급"
                ) {
                    selectedSkillLevel = "고급"
                    onFilterChange()
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, -24)
    }
}

#Preview {
    FilterButtonsView(
        regions: [
            RegionData(id: "region1", name: "서울시", parentRegion: nil, coordinates: Coordinates(latitude: 37.5665, longitude: 126.9780)),
            RegionData(id: "region2", name: "송파구", parentRegion: "서울시", coordinates: Coordinates(latitude: 37.5145, longitude: 127.1056))
        ],
        selectedRegion: .constant(nil),
        selectedSkillLevel: .constant(nil),
        onFilterChange: {}
    )
}
