//
//  MyMatchTagView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI


/// 경기정보 태그 스타일
struct MatchTagStyle: ViewModifier {
    var matchTag: MatchInfoTag
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .foregroundStyle(matchTag.textColor)
            .background(matchTag.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(matchTag.borderColor.opacity(0.2), lineWidth: 1)
            )
    }
}


struct MyMatchTagView: View {
    let matchInfo: MatchInfo
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 태그
            HStack(spacing: 10) {
                Text(matchInfo.matchType.rawValue)
                    .matchTagStyle(tagType: matchInfo.matchType == .futsal ? .futsal : .soccer)
                
                
                if matchInfo.maxCount - matchInfo.applyCount == 1 {
                    Text(MatchInfoTag.lastOne.rawValue)
                        .matchTagStyle(tagType: .lastOne)
                } else {
                    Text(MatchInfoTag.deadline.rawValue)
                        .matchTagStyle(tagType: .deadline)
                }
            }
            
            Spacer()
            
            // x버튼
            Button {
                print("x버튼 탭")
            } label: {
                Image(systemName: "xmark")
            }
            .padding(.horizontal, 10)
            .foregroundStyle(Color.black)
        }
    }
}
