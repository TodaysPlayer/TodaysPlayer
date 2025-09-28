//
//  MyMatchInfoView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// 경기정보 View
struct MyMatchInfoView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                // 제목
                Text(matchInfo.matchTitle)
                    .font(.headline)
                
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
            }
            
            // 인원수
            HStack {
                Image(systemName: "person.fill")
                
                if let firstChar = matchInfo.matchTime.first {
                    Text(matchInfo.matchTime.highlighted(part: String(firstChar), color: .green))
                }
                
                ProgressView(value: 0.6)
                    .progressViewStyle(.linear)
                    .tint(.green)
                    .frame(height: 12)
                    .padding(.horizontal)
                
            }
            
            // 참여비 성별 실력
            HStack {
                Image(systemName: "person.fill")
                Text("\(matchInfo.matchFee)")
                
                Spacer()
                
                Image(systemName: "person.fill")
                Text(matchInfo.genderLimit)
                
                Spacer()
                
                Image(systemName: "person.fill")
                Text(matchInfo.levelLimit)
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
//
//#Preview {
//    MyMatchInfoView()
//}
