//
//  MyMatchView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// MyMatchView
/// - 내가 신청 / 작성한 경기
struct MyMatchView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        VStack(spacing: 20) {
            MyMatchTagView(matchInfo: matchInfo)
                    
            MyMatchInfoView(matchInfo: matchInfo)
        }
    }
}
