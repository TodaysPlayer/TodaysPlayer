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
    
    @Binding var isFinishedMatch: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목
            Text(matchInfo.title)
                .foregroundStyle(Color.black)
                .font(.headline)
                .bold()
            
            // participants에서 유저아이디로 내가 있는지 걸르고 그거에 상태를 확인해야함
            // 거절된 경기의 경우 이름을 빈칸으로 확인하고 있는데 이걸 고쳐야할듯
            MatchInfoDetailView(matchInfo: matchInfo)
                .visible(apply.status != .rejected)
        
            Text("경기 주최자의 거절사유입니다.")
                .visible(apply.status == .rejected && postedMatchCase != .myRecruitingMatch)
            
            // 매치상태가 거절이 아니라 applystatus가 거절이면
            Text(apply.rejectReason)
                .modifier(DescriptionTextStyle())
                .visible(apply.status == .rejected && postedMatchCase != .myRecruitingMatch)
            
            Divider()
                .visible(postedMatchCase == .appliedMatch && matchInfo.organizerId != apply.userId)
            
            HStack {
                Image(systemName: "person.fill")
                    .clipShape(.circle)
                
                Text(matchInfo.organizerName)
                
                Spacer()
            }
            .visible(postedMatchCase == .appliedMatch && matchInfo.organizerId != apply.userId)
            
            Button("경기 종료하기"){
                // 서버에 데이터 쏴주고 수정된 데이터로 모집중인 매치, 종료된 매치 수정
                print("시마이")
                isFinishedMatch = matchInfo.id
            }
            .modifier(MyMatchButtonStyle())
            .visible(postedMatchCase == .myRecruitingMatch && matchInfo.status != "finished")
            
            NavigationLink {
                PlayerRatingView(viewModel: PlayerRatingViewModel(matchInfo: matchInfo))
            } label: {
                Text("참여자 평가하기")
                    .modifier(MyMatchButtonStyle())

            }
            .visible(postedMatchCase == .finishedMatch && matchInfo.organizerId == apply.userId)
        }
        .foregroundStyle(Color.black)
        
    }
}

