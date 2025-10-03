//
//  MatchDashboardView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// MatchList DashBoard Component
struct MatchDashboardComponentView: View {
    var buttonTitle: String
    @Binding var selectedTitle: String
    
    var body: some View {
        Button {
            selectedTitle = buttonTitle
        } label: {
            Text(buttonTitle)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedTitle == buttonTitle ? .green.opacity(0.1) : .gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            selectedTitle == buttonTitle ? Color.green.opacity(0.8) : Color.gray.opacity(0.8),
                            lineWidth: 2
                        )
                }
        }
    }
}



/// MatchList DashBoard
/// - 나의 매치 필터링 버튼
/// 클로져달기
struct MyMatchFilterButtonView: View {
    var titles: [String]
    @Binding var selectedTitle: String 
        
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(titles, id: \.self) { title in
                    MatchDashboardComponentView(
                        buttonTitle: title,
                        selectedTitle: $selectedTitle
                    )
                }
            }
        }
    }
}
