//
//  MyMatchTagView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


struct MatchTagView: View {
    let matchInfo: Match
    let postedMatchCase: PostedMatchCase
    private var leftPersonCount: Int
    
    init(info: Match, matchCase: PostedMatchCase) {
        self.matchInfo = info
        self.postedMatchCase = matchCase
        
        let participants = matchInfo.participants.map { (_, value: String) in
            value != "rejected"
        }.count
        
        self.leftPersonCount = matchInfo.maxParticipants - participants
    }
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 태그
            HStack(spacing: 10) {
                Text(matchInfo.convertMatchType(type: matchInfo.matchType).rawValue)
                    .matchTagStyle(tagType: matchInfo.convertMatchType(type: matchInfo.matchType).rawValue == MatchType.futsal.rawValue ? MatchType.futsal : MatchType.soccer)
                
                // 조건부 : 신청상태( 확정/대기중/거절 )
                
//                Text(matchInfo.convertMatchType(type: matchInfo.status).rawValue)
//                    .matchTagStyle(tagType: matchInfo.applyStatus)
//                    .visible(postedMatchCase == .appliedMatch)
//                
//                Text(MatchInfoStatus.lastOne.rawValue)
//                    .matchTagStyle(tagType: MatchInfoStatus.lastOne)
//                    .visible(leftPersonCount == 1 && matchInfo.applyStatus != .rejected)
//                
//                Text(MatchInfoStatus.deadline.rawValue)
//                    .matchTagStyle(tagType: MatchInfoStatus.deadline)
//                    .visible(leftPersonCount != 1 && matchInfo.applyStatus != .rejected)
//                
            }
            .font(.system(size: 14))
            
            Spacer()
        }
    }
}

