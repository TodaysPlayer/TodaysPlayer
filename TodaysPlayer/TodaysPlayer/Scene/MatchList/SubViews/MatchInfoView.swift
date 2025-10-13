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
    let matchInfo: Match
    let postedMatchCase: PostedMatchCase
    let userName: String
//    let applyStatus: Apply
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목
            Text(matchInfo.title)
                .foregroundStyle(Color.black)
                .font(.headline)
                .bold()
            
            // participants에서 유저아이디로 내가 있는지 걸르고 그거에 상태를 확인해야함
            MatchInfoDetailView(matchInfo: matchInfo)
                .visible(matchInfo.covertApplyStatus(status: matchInfo.status) != .rejected)
            
            Text("경기 주최자의 거절사유입니다.")
                .visible(matchInfo.covertApplyStatus(status: matchInfo.status) == .rejected)
            
//            Text(applyStatus.rejectionReason ?? "")
//                .modifier(DescriptionTextStyle())
//                .visible(matchInfo.covertApplyStatus(status: matchInfo.status) == .rejected)
            
            Divider()
                .visible(postedMatchCase != .myRecruitingMatch)
            
            HStack {
                Image(systemName: "person.fill")
                    .clipShape(.circle)
                
                Text(matchInfo.organizerName)
                
                Spacer()
            }
            .visible(postedMatchCase != .myRecruitingMatch)
            
            
            NavigationLink {
                PlayerRatingView(viewModel: PlayerRatingViewModel(matchInfo: matchInfo))
            } label: {
                Text("참여자 평가하기")
            }
            .visible(postedMatchCase == .finishedMatch && matchInfo.organizerName == userName)
        }
        .foregroundStyle(Color.black)
        
    }
}

