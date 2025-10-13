//
//  FinishedMatchView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/10/25.
//

import SwiftUI


/// 종료된 경기 화면
struct FinishedMatchView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(matchInfo.matchType.rawValue)
                .matchTagStyle(tagType: matchInfo.matchType)
            
            Text(matchInfo.matchTitle)
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                Image(systemName: "clock")
                Text(matchInfo.matchTime)
            }
            HStack {
                Image(systemName: "location")
                Text(matchInfo.matchLocation)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
}
