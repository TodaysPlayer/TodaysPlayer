//
//  MyRatingPageDescriptionView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/13/25.
//

import SwiftUI

struct MyRatingPageDescriptionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("평기 점수 활용 안내")
                .font(.headline)
            
            Text("""
                 평가 점수는 함께 경기한 사용자들의 경험을 바탕으로 작성된 것으로,\
                 높은 평가는 신뢰도 있는 플레이어임을 나타냅니다.
                 """)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineSpacing(6)

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1, y: 1)
    }
}
