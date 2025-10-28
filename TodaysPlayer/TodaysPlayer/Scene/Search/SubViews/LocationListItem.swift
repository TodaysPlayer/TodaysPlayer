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
                    .foregroundStyle(isSelected ? Color.futsalGreen : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    // 장소 이름
                    Text(mapItem.name ?? "이름 없음")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    // 주소
                    if let address = mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false) {
                        Text(removePostalCode(from: address))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.futsalGreen)
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
    
    /// 우편번호(5자리 숫자)를 문자열에서 제거
    private func removePostalCode(from address: String) -> String {
        var result = address
        
        // 맨 앞의 5자리 숫자 제거
        result = result.replacingOccurrences(of: "^\\d{5}\\s*", with: "", options: .regularExpression)
        
        // 맨 끝의 5자리 숫자 제거
        result = result.replacingOccurrences(of: "\\s*\\d{5}$", with: "", options: .regularExpression)
        
        // 연속된 공백 정리
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespaces)
        
        return result
    }
}
