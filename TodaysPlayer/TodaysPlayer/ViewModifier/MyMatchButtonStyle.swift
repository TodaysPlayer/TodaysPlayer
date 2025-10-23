//
//  MyMatchButtonStyle.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/21/25.
//

import SwiftUI

/// 나의 경기 버튼 스타일
struct MyMatchButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green)
            .cornerRadius(12)
    }
}
