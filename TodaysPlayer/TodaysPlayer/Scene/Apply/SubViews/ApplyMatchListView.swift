//
//  ApplyMatchListView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/29/25.
//

import SwiftUI

struct ApplyMatchListView: View {
    let matchList: [MatchInfo] = mockMatchData
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(matchList, id: \.matchId) { match in
                NavigationLink(destination: ApplyMatchDetailView(matchInfo: match)) {
                    MyMatchView(matchInfo: match)
                }
                .buttonStyle(PlainButtonStyle()) // NavigationLink의 기본 파란색 제거
            }
        }
    }
}
