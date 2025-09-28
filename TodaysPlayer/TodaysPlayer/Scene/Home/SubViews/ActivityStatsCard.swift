//
//  ActivityStatsCard.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct ActivityStatsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "trophy")
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                    .padding(.trailing, 3)
                
                Text("내 활동 통계")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 통계 항목들
            VStack(spacing: 16) {
                // 이번 달 참여
                StatItemView(
                    icon: "circle.circle.fill",
                    title: "이번 달 참여",
                    value: "8회",
                    valueColor: .black,
                    iconColor: .blue
                )
                
                // 출석률
                StatItemView(
                    icon: nil,
                    title: "출석률",
                    value: "85%",
                    valueColor: .green,
                    iconColor: .clear,
                    progress: 0.85
                )
                
                // 노쇼율
                StatItemView(
                    icon: "exclamationmark.triangle.fill",
                    title: "노쇼율",
                    value: "5%",
                    valueColor: .red,
                    valueBackgroundColor: .red,
                    valueTextColor: .white,
                    iconColor: .red
                )
                
                // 연속 참여
                StatItemView(
                    icon: "flame.fill",
                    title: "연속 참여",
                    value: "3주째",
                    valueColor: .orange,
                    iconColor: .orange
                )
                
                Divider()
                
                // 신뢰도
                StatItemView(
                    icon: nil,
                    title: "신뢰도",
                    value: "Silver",
                    valueColor: .gray,
                    valueBackgroundColor: .gray,
                    valueTextColor: .white,
                    iconColor: .clear
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    ActivityStatsCard()
}
