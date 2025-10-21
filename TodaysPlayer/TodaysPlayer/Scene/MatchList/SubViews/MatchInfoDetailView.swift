//
//  MatchInfoDetailView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/13/25.
//

import SwiftUI

struct MatchInfoDetailView: View {
    let matchInfo: Match
    
    var body: some View {
        // 시간
        HStack {
            Image(systemName: "fitness.timer")
            Text(matchInfo.dateTime.formatForDisplay())
        }
        
        // 장소
        HStack {
            Image(systemName: "location")
            Text(matchInfo.location.name)
        }
        
        
        // 인원수
        HStack {
            Image(systemName: "person.fill")
            
            let participants = matchInfo.participants.map { (_, value: String) in
                value != "rejected"
            }.count
            let personCount = "\(participants) / \(matchInfo.maxParticipants)"
            
            Text(personCount.highlighted(part: String(participants), color: .green))
            
            let progressValue: Double = Double(participants) / Double(matchInfo.maxParticipants)
            
            ProgressView(value: progressValue, total: 1.0)
                .progressViewStyle(LinearGaugeProgressStyle())
                .frame(height: 20)
            
            Spacer()
        }
        
        // 참여비 성별 실력
        HStack {
            Image(systemName: "wonsign.circle")
            Text("\(matchInfo.price)원")
            
            Spacer()
            
            Image(systemName: "figure.2.arms.open")
            Text(matchInfo.gender)
            
            Spacer()
            
            Image(systemName: "person.fill")
            Text(matchInfo.skillLevel)
            
            Spacer()
        }
    }
}
