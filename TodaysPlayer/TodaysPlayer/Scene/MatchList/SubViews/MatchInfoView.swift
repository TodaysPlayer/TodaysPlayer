//
//  MyMatchInfoView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
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
    }
}

/// 경기정보 View
/// 거절된거 다르게 표시
/// 내가 모집한 경기 가 끝났으면 평가하기 버튼 추가
struct MatchInfoView: View {
    let matchInfo: MatchInfo
    let postedMatchCase: PostedMatchCase
    let userName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 제목
            Text(matchInfo.matchTitle)
                .font(.headline)
                .bold()
            
            MatchInfoDetailView(matchInfo: matchInfo)
                .visible(matchInfo.applyStatus != .rejected)
            
            Text("경기 주최자의 거절사유입니다.")
                .visible(matchInfo.applyStatus == .rejected)

            Text(matchInfo.rejectionReason)
                .modifier(DescriptionTextStyle())
                .visible(matchInfo.applyStatus == .rejected)
            
            Divider()
                .visible(postedMatchCase != .myRecruitingMatch)
            
            HStack {
                Image(systemName: "person.fill")
                    .clipShape(.circle)
                
                Text(matchInfo.postUserName)
                
                Spacer()
            }
            .visible(postedMatchCase != .myRecruitingMatch)
            
            Button("참여자 평가하기") {
                print("평가데스")
            }
            .visible(postedMatchCase == .finishedMatch && matchInfo.postUserName == userName)
        }
    }
}

