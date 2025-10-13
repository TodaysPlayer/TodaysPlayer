//
//  MatchInfoDetailView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/13/25.
//

import SwiftUI

struct MatchInfoDetailView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        // 시간
        HStack {
            Image(systemName: "fitness.timer")
            Text(matchInfo.matchTime)
        }
        
        // 장소
        HStack {
            Image(systemName: "location")
            Text(matchInfo.matchLocation)
        }
        
        
        // 인원수
        HStack {
            Image(systemName: "person.fill")
            
            let personCount = "\(matchInfo.applyCount) / \(matchInfo.maxCount)"
            
            Text(personCount.highlighted(part: String(matchInfo.applyCount), color: .green))
            
            let progressValue: Double = Double(matchInfo.applyCount) / Double(matchInfo.maxCount)
            
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearGaugeProgressStyle())
                .frame(height: 20)
            
            Spacer()
        }
        
        // 참여비 성별 실력
        HStack {
            Image(systemName: "person.fill")
            Text("\(matchInfo.matchFee)원")
            
            Spacer()
            
            Image(systemName: "person.fill")
            Text(matchInfo.genderLimit)
            
            Spacer()
            
            Image(systemName: "person.fill")
            Text(matchInfo.levelLimit)
            
            Spacer()
        }
    }
}
