//
//  MyMatchTagView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


struct MatchTagView: View {
    let matchInfo: MatchInfo
    let postedMatchCase: PostedMatchCase
    private var leftPersonCount: Int
    
    init(info: MatchInfo, matchCase: PostedMatchCase) {
        self.matchInfo = info
        self.postedMatchCase = matchCase
        self.leftPersonCount = matchInfo.maxCount - matchInfo.applyCount
    }
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 태그
            HStack(spacing: 10) {
                Text(matchInfo.matchType.rawValue)
                    .matchTagStyle(tagType: matchInfo.matchType.rawValue == MatchType.futsal.rawValue ? MatchType.futsal : MatchType.soccer)
                
                // 조건부 : 신청상태( 확정/대기중/거절 )
                
                Text(matchInfo.applyStatus.rawValue)
                    .matchTagStyle(tagType: matchInfo.applyStatus)
                    .visible(postedMatchCase == .appliedMatch)
                
                Text(MatchInfoStatus.lastOne.rawValue)
                    .matchTagStyle(tagType: MatchInfoStatus.lastOne)
                    .visible(leftPersonCount == 1 && matchInfo.applyStatus != .rejected)
                
                Text(MatchInfoStatus.deadline.rawValue)
                    .matchTagStyle(tagType: MatchInfoStatus.deadline)
                    .visible(leftPersonCount != 1 && matchInfo.applyStatus != .rejected)
                
            }
            .font(.system(size: 14))
            
            Spacer()
        }
    }
}

