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
    let testMatchData: MatchInfo = MatchInfo(
        matchId: "",
        matchType: .futsal,
        applyStatus: .confirmed,
        matchLocation: "연수구",
        matchTitle: "Test",
        matchTime: "08:00~10:00",
        applyCount: 10,
        maxCount: 12,
        matchFee: 3000,
        genderLimit: "무관",
        levelLimit: "무관",
        imageURL: "",
        postUserName: "용헌"
    )
    
    var body: some View {
        VStack {

            MyMatchTagView(matchInfo: testMatchData)
            
            // 경기정보
            MyMatchInfoView(matchInfo: testMatchData)
            
        }

        
        
        //제목
        
        // 날짜 및 시간
        
        // 풋살장 장소
        
        // 인원수
        
        
    }
}

#Preview {
    MyMatchView()
}

