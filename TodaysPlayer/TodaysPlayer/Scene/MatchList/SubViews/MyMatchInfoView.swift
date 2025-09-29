//
//  MyMatchInfoView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI

private struct LinearGaugeProgressStyle: ProgressViewStyle {
    var tintColor: Color = .green
    var backgroundColor: Color = .gray.opacity(0.2)
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                
                Capsule()
                    .fill(tintColor)
                    .frame(width: fractionCompleted * geometry.size.width)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}


/// 경기정보 View
struct MyMatchInfoView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목
            Text(matchInfo.matchTitle)
                .font(.headline)
                .bold()
            
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
                
                let personCount = "\(matchInfo.applyCount)/\(matchInfo.maxCount)"
                
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
            
            Divider()
            
            HStack {
                Image(systemName: "person.fill")
                    .clipShape(.circle)
                
                Text(matchInfo.postUserName)
                
                Spacer()
            }
        }
    }
}

#Preview {
    MyMatchInfoView(matchInfo: MatchInfo(
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
    ))
}
