//
//  MyMatchInfoView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// 경기정보 View
/// 거절된거 다르게 표시
/// 내가 모집한 경기 가 끝났으면 평가하기 버튼 추가
struct MatchInfoView: View {
    let matchInfo: MatchInfo
    let postedMatchCase: PostedMatchCase
    let userName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목
            Text(matchInfo.matchTitle)
                .foregroundStyle(Color.black)
                .font(.headline)
                .bold()
            
            MatchInfoDetailView(matchInfo: matchInfo)
                .visible(matchInfo.applyStatus != .rejected)
            
            Text("경기 주최자의 거절사유입니다.")
                .visible(matchInfo.applyStatus == .rejected)
            
            Text(matchInfo.rejectionReason)
                .modifier(DescriptionTextStyle())
                .visible(matchInfo.applyStatus == .rejected)
            
            Divider()
                .visible(postedMatchCase != .myRecruitingMatch)
            
            HStack {
                Image(systemName: "person.fill")
                    .clipShape(.circle)
                
                Text(matchInfo.postUserName)
                
                Spacer()
            }
            .visible(postedMatchCase != .myRecruitingMatch)
            
            
            NavigationLink {
                PlayerRatingView(viewModel: PlayerRatingViewModel(matchInfo: matchInfo))
            } label: {
                Text("참여자 평가하기")
            }
            .visible(postedMatchCase == .finishedMatch && matchInfo.postUserName == userName)
        }
        .foregroundStyle(Color.black)
        
    }
}

