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
    let apply: (userId: String, rejectReason: String, status: ApplyStatus)   // 신청자Id: 참여상태
    let matchTagInfo: (matchType: String, appliedStatus: ApplyStatus, leftPersonCount: Int)

    @Binding var finishedMatchId: String
    @Binding var finishedMatchWithRatingId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목
            Text(matchInfo.title)
                .foregroundStyle(Color.black)
                .font(.headline)
                .bold()
            
            MatchTagView(info: matchTagInfo, matchCase: postedMatchCase)
            
            MatchInfoDetailView(matchInfo: matchInfo)
                .visible(apply.status != .rejected)
            
            Text("경기 주최자의 거절사유입니다.")
                .visible(apply.status == .rejected && postedMatchCase != .myRecruitingMatch)
            
            Text(apply.rejectReason)
                .modifier(DescriptionTextStyle())
                .multilineTextAlignment(.leading)
                .visible(apply.status == .rejected && postedMatchCase != .myRecruitingMatch)
            
            Divider()
                .visible(postedMatchCase == .appliedMatch && matchInfo.organizerId != apply.userId)
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.gray)
                
                Text(matchInfo.organizerName)
                
                Spacer()
            }
            .visible(postedMatchCase == .appliedMatch && matchInfo.organizerId != apply.userId)
            
            Button("경기 종료하기"){
                finishedMatchId = matchInfo.id
            }
            .modifier(MyMatchButtonStyle())
            .visible(postedMatchCase == .myRecruitingMatch && matchInfo.status != "finished")
            
            NavigationLink {
                PlayerRatingView(viewModel: PlayerRatingViewModel(matchInfo: matchInfo)) {
                    finishedMatchWithRatingId = matchInfo.id
                }
                
            } label: {
                Text("참여자 평가하기")
                    .modifier(MyMatchButtonStyle())
            }
            .visible(
                shouldShowRatingButton(
                for: matchInfo,
                userId: apply.userId,
                postedMatchCase: postedMatchCase
                )
            )
            
        }
        .foregroundStyle(Color.black)
        
    }
    
    private func shouldShowRatingButton(
        for matchInfo: Match,
        userId: String,
        postedMatchCase: PostedMatchCase
    ) -> Bool {
        guard postedMatchCase == .finishedMatch else { return false }
        guard matchInfo.organizerId == userId else { return false }
        guard matchInfo.rating == nil else { return false }
        let acceptedCount = matchInfo.participants.values.filter { $0 == ApplyStatusConverter.toString(from: .accepted) }.count
        return acceptedCount > 0
    }
}
