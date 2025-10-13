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
            ForEach(viewModel.ratingList, id: \.1) { (icon, title) in
                StarRatingView(
                    rating: Binding(
                        get: { viewModel.ratings[userInfo.id]?[title] ?? 0 },
                        set: {
                            if viewModel.ratings[userInfo.id] == nil {
                                viewModel.ratings[userInfo.id] = [:]
                            }
                            viewModel.ratings[userInfo.id]?[title] = $0
                        }
                    ),
                    imageName: icon,
                    title: title
                )
            }
            
            Text("코멘트")
                .font(.subheadline)
            
            TextEditor(
                text: Binding(get: { viewModel.comments[userInfo.id] ?? ""},
                              set: { viewModel.comments[userInfo.id] = $0})
            )
            .frame(minHeight: 80)
            .padding(6)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3))
            )
            
            Button("평가 완료") {
                viewModel.completedRatings.insert(userInfo.id)
                viewModel.expandedUserID = nil
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
        }
        .padding(.top, 8)
    }
}
