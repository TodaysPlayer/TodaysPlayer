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
                .foregroundStyle(selectedTitle == buttonType ? Color.white : Color.secondaryDeepGray)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedTitle == buttonType ? Color.primaryBaseGreen : Color.white)
                .cornerRadius(16)
        }
    }
}


/// MatchList DashBoard
/// - 나의 매치 필터링 버튼
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

