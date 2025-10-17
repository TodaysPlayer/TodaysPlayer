//
//  PlayerRatingListView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/10/25.
//

import SwiftUI

/// 참여자 평가항목 화면
struct PlayerRatingListView: View {
    let userInfo: User
    @State var viewModel: PlayerRatingViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(UserRatingCategory.allCases, id: \.self) { category in
                StarRatingView(
                    rating: Binding(
                        get: { viewModel.ratings[userInfo.id]?[category] ?? 0 },
                        set: {
                            if viewModel.ratings[userInfo.id] == nil {
                                viewModel.ratings[userInfo.id] = [:]
                            }
                            viewModel.ratings[userInfo.id]?[category] = $0
                        }
                    ),
                    imageName: category.iconName,
                    title: category.title
                )
            }
        }
        .padding(.top, 8)
    }
}
