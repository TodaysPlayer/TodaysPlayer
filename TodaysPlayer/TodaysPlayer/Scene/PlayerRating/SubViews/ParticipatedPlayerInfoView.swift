//
//  ParticipatedPlayerInfoView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/10/25.
//

import SwiftUI


/// 참여자 정보 화면
struct ParticipatedPlayerInfoView: View {
    let userInfo: User
    @State var viewModel: PlayerRatingViewModel

    var body: some View {
        let isCompleted = viewModel.checkCompledtedRating(userInfo.id)
        let isExpanded = viewModel.expandedUserID == userInfo.id
        
        HStack {
            // 참가자 정보
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userInfo.displayName)
                    .font(.headline)
                Text("\(userInfo.position ?? "포지션 무관")  \(userInfo.skillLevel ?? "실력 무관")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 참가자 평가 버튼
            Button {
                viewModel.toggleExpanded(userInfo.id)
            } label: {
                Text(setupButtonTitle(isCompleted: isCompleted, isExpanded: isExpanded))
                    .font(.subheadline)
                    .foregroundColor(isCompleted ? .green : .blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background((isCompleted ? Color.green : Color.blue).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    private func setupButtonTitle(isCompleted: Bool, isExpanded: Bool) -> String {
        if isCompleted {
            return isExpanded ? "닫기" : "수정하기"
        } else {
            return isExpanded ? "닫기" : "평가하기"
        }
    }
}
