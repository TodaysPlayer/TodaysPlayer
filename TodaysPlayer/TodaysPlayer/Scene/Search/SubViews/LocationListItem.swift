//
//  LocationListItem.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import SwiftUI
import MapKit

struct LocationListItem: View {
    let mapItem: MKMapItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                // 아이콘
                Image(systemName: isSelected ? "mappin.circle.fill" : "mappin.circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    // 장소 이름
                    Text(mapItem.name ?? "이름 없음")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // 주소
                    if let address = mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false) {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
