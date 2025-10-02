//
//  MyPageRowView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
// 마이페이지의 메뉴 리스트 한 행을 표시하는 뷰
// - 좌측 아이콘, 제목/부제목, 우측 이동 화살표로 구성됩니다.
struct MyPageRowView: View {
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

