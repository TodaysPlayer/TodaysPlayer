//
//  MyMatchTagView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import SwiftUI

/// 경기정보 태그 enum
enum MatchInfoTag: String {
    case futsal = "풋살"
    case soccer = "축구"
    case deadline = "마감임박"
    case lastOne = "너만 오면 GO"
    case location
    
    var backgroundColor: Color {
        switch self {
        case .futsal: .green
        case .soccer: .blue
        case .deadline: .red
        case .lastOne:  .orange
        case .location: .mint
        }
    }
    
    var textColor: Color {
        switch self {
        case .futsal: .white
        case .soccer: .white
        case .deadline: .white
        case .lastOne:  .white
        case .location: .white
        }
    }
    
    var borderColor: Color {
        switch self {
        case .futsal: .green
        case .soccer: .blue
        case .deadline: .red
        case .lastOne:  .orange
        case .location: .mint
        }
    }
}


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
                
                #warning("데드라인 어떻게 설정할지 정해야함")
                Text(MatchInfoTag.deadline.rawValue)
                    .matchTagStyle(tagType: .deadline)
                
                if matchInfo.maxCount - matchInfo.applyCount == 1 {
                    Text(MatchInfoTag.lastOne.rawValue)
                        .matchTagStyle(tagType: .lastOne)
                }
                
                Text(matchInfo.matchLocation)
                    .matchTagStyle(tagType: .location)
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
        .padding(.horizontal)
    }
}

//#Preview {
//    MyMatchTagView()
//}
