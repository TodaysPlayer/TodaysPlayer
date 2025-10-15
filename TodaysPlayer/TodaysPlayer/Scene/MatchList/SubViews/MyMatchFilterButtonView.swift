//
//  MatchDashboardView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// MatchList DashBoard Component
struct MatchDashboardComponentView<T: MatchFilterType>: View {
    var buttonType: T
    @Binding var selectedTitle: T

    var body: some View {
        Button {
            selectedTitle = buttonType
        } label: {
            Text(buttonType.title)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedTitle == buttonType ? .green.opacity(0.1) : .gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            selectedTitle == buttonType ? Color.green.opacity(0.8) : Color.gray.opacity(0.8),
                            lineWidth: 2
                        )
                }
        }
    }
}




/// MatchList DashBoard
/// - 나의 매치 필터링 버튼
/// 클로져달기
struct MyMatchFilterButtonView<T: MatchFilterType>: View {
    var filterTypes: [T]
    @Binding var selectedFilter: T

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(filterTypes, id: \.self) { type in
                    MatchDashboardComponentView(
                        buttonType: type,
                        selectedTitle: $selectedFilter
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

