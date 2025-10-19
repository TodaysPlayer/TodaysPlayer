//
//  MyMatchTagView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


struct MatchTagView: View {
    let matchInfo: (matchType: String, appliedStatus: ApplyStatus, leftPersonCount: Int)
    let postedMatchCase: PostedMatchCase
    
    init(info: (String, ApplyStatus, Int), matchCase: PostedMatchCase) {
        self.matchInfo = info
        self.postedMatchCase = matchCase
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 태그
            HStack(spacing: 10) {
                Text(matchInfo.matchType)
                    .matchTagStyle(tagType: matchInfo.matchType == MatchType.futsal.rawValue
                                   ? MatchType.futsal : MatchType.soccer)
                
                // 조건부 : 신청상태( 확정/대기중/거절 )
                
                Text(matchInfo.appliedStatus.rawValue)
                    .matchTagStyle(tagType: matchInfo.appliedStatus)
                    .visible(postedMatchCase == .appliedMatch)
                
                Text(MatchInfoStatus.lastOne.rawValue)
                    .matchTagStyle(tagType: MatchInfoStatus.lastOne)
                    .visible(matchInfo.leftPersonCount == 1 && matchInfo.appliedStatus != .rejected)
                
                Text(MatchInfoStatus.deadline.rawValue)
                    .matchTagStyle(tagType: MatchInfoStatus.deadline)
                    .visible(matchInfo.leftPersonCount != 1 && matchInfo.appliedStatus != .rejected)
                
            }
            .font(.system(size: 14))
            
            Spacer()
        }
    }
}

