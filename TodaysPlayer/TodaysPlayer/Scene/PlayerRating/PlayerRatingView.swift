//
//  PlayerRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/8/25.
//

import SwiftUI


/// 참여자 평가화면
struct PlayerRatingView: View {
    let viewModel: PlayerRatingViewModel
    let onCompletedBtnTapped: () -> ()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            // 종료된 매치 정보
            VStack(alignment: .leading) {
                FinishedMatchView(matchInfo: viewModel.matchInfo)
                    .padding()
                
                // 매치에 참여한 참가자 목록
                Text("참여자 목록")
                    .font(.headline)
                    .padding(.leading, 12)
                

                
                List(viewModel.participatedUsers, id: \.self) { user in
                    VStack(alignment: .leading, spacing: 12) {
                        ParticipatedPlayerInfoView(userInfo: user, viewModel: viewModel)
                        
                        PlayerRatingListView(userInfo: user, viewModel: viewModel)
                            .visible(viewModel.expandedUserID == user.id)
                        
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .listRowSpacing(10)
                .listStyle(.plain)
                .padding()
                .scrollContentBackground(.hidden)
                
                Text("- 평가하지 않은 참여자 및 항목은 평균점수(4점)으로 간주됩니다.")
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
               
                Button(action: {
                    Task {
                       await viewModel.updateUserRate()
                    }
                    
                    dismiss()
                    onCompletedBtnTapped()
                }) {
                    Text("평가 완료")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .task({
            await viewModel.fetchUserData()
        })
        .navigationTitle("참여자 평가하기")
    }
    
}
