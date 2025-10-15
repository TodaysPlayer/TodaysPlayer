//
//  StatView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI

// 통계 뷰
struct Stat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(25)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct MyPageRow: View {
    // SF Symbols 아이콘 이름
    let icon: String
    // 아이콘 색상
    let iconColor: Color
    // 행 타이틀
    let title: String
    // 행 부제목(설명)
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(iconColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        // 카드형 배경을 위한 모서리 둥글기
        .cornerRadius(14)
    }
}

#Preview {
    MyPageView()
}
