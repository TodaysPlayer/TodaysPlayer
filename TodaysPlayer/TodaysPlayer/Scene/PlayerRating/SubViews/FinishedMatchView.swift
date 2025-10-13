//
//  FinishedMatchView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/10/25.
//

import SwiftUI


/// 종료된 경기 화면
struct FinishedMatchView: View {
    let matchInfo: Match
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(matchInfo.convertMatchType(type: matchInfo.matchType).rawValue)
                .matchTagStyle(tagType: matchInfo.convertMatchType(type: matchInfo.matchType))
            
            Text(matchInfo.title)
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                Image(systemName: "clock")
                Text(matchInfo.dateTime.formatted())
            }
            HStack {
                Image(systemName: "location")
                Text(matchInfo.location.name)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
}
