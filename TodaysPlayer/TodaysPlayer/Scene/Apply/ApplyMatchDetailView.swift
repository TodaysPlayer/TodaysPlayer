//
//  ApplyMatchDetailView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/29/25.
//

import SwiftUI

struct ApplyMatchDetailView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 상세 정보 표시
            }
            .padding()
        }
        .navigationTitle(matchInfo.matchTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
