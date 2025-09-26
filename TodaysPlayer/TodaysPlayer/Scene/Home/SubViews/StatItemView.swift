//
//  StatItemView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct StatItemView: View {
    let icon: String?
    let title: String
    let value: String
    let valueColor: Color
    let valueBackgroundColor: Color?
    let valueTextColor: Color?
    let iconColor: Color
    let progress: Double?
    
    init(
        icon: String?,
        title: String,
        value: String,
        valueColor: Color,
        valueBackgroundColor: Color? = nil,
        valueTextColor: Color? = nil,
        iconColor: Color,
        progress: Double? = nil
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
        self.valueBackgroundColor = valueBackgroundColor
        self.valueTextColor = valueTextColor
        self.iconColor = iconColor
        self.progress = progress
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 아이콘 (있는 경우에만)
                if let icon = icon, icon != "" {
                    if icon == "circle.circle.fill" {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 8, height: 8)
                        }
                    } else {
                        Image(systemName: icon)
                            .foregroundColor(iconColor)
                            .font(.system(size: 16))
                    }
                }
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                // 값 표시
                if let backgroundColor = valueBackgroundColor {
                    Text(value)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(valueTextColor ?? valueColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text(value)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(valueColor)
                }
            }
            
            // 진행률 바 (출석률에만 표시)
            if let progress = progress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: geometry.size.width * progress, height: 6)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

#Preview {
    StatItemView(
        icon: "circle.circle.fill",
        title: "이번 달 참여",
        value: "8회",
        valueColor: .black,
        iconColor: .blue
    )
}
