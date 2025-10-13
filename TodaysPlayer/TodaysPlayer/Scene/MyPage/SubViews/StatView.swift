//
//  StatView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI

// 통계 뷰
struct StatView: View {
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
                .font(.system(size: 22, weight: .bold))
            Text(label)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(25)
        .background(Color.white)
        .cornerRadius(16)
    }
}
