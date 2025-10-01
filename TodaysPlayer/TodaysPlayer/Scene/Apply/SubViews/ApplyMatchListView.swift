//
//  ApplyMatchListView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/29/25.
//

import SwiftUI

struct ApplyMatchListView: View {
    let filter: GameFilter
    
    let matchList: [MatchInfo] = mockMatchData
    
    // 필터링된 매치 목록
    var filteredMatches: [MatchInfo] {
        matchList.filter { match in
            // matchType 필터
            if let filterMatchType = filter.matchType,
               match.matchType != filterMatchType {
                return false
            }
            
            // skillLevels 필터 (복수 선택)
            if !filter.skillLevels.isEmpty {
                let hasMatchingLevel = filter.skillLevels.contains { skillLevel in
                    match.levelLimit == skillLevel.rawValue
                }
                if !hasMatchingLevel {
                    return false
                }
            }
            
            // gender 필터
            if let filterGender = filter.gender,
               match.genderLimit != filterGender.rawValue {
                return false
            }
            
            // feeType 필터
            if let filterFeeType = filter.feeType {
                switch filterFeeType {
                case .free:
                    if match.matchFee != 0 { return false }
                case .paid:
                    if match.matchFee == 0 { return false }
                }
            }
            
            return true
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredMatches, id: \.matchId) { match in
                NavigationLink(destination: ApplyMatchDetailView(
                    matchInfo: match,
                    postedMatchCase: .allMatches
                    )
                ) {
                    VStack(spacing: 20) {
                        MatchTagView(matchInfo: match, postedMatchCase: .allMatches)
                        
                        MatchInfoView(matchInfo: match, postedMatchCase: .allMatches)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.primary.opacity(0.1), radius: 4, x: 0, y: 2)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 필터링 결과가 없을 때 메시지
            if filteredMatches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("조건에 맞는 경기가 없습니다")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("다른 조건으로 검색해보세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            }
        }
    }
}
