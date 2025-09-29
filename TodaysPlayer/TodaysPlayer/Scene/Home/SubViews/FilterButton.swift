//
//  FilterButton.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        FilterButton(title: "전체", isSelected: true, action: {})
        FilterButton(title: "서울시", isSelected: false, action: {})
        FilterButton(title: "중급", isSelected: false, action: {})
    }
    .padding()
}
