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
    @State private var isShowAlert: Bool = false
    let matchInfo: MatchInfo
    var showDeleteButton: Bool = false // 삭제버튼 표시여부
    var showApplyStatus: Bool = false // 신청상태 표시 여부
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 태그
            HStack(spacing: 10) {
                Text(matchInfo.matchType.rawValue)
                    .matchTagStyle(tagType: matchInfo.matchType.rawValue == MatchType.futsal.rawValue ? MatchType.futsal : MatchType.soccer)
                
                // 조건부 : 신청상태( 확정/대기중/거절 )
                if showApplyStatus {
                    Text(matchInfo.applyStatus.rawValue)
                        .matchTagStyle(tagType: matchInfo.applyStatus)
                }
                
                if matchInfo.maxCount - matchInfo.applyCount == 1 {
                    Text(MatchInfoStatus.lastOne.rawValue)
                        .matchTagStyle(tagType: MatchInfoStatus.lastOne)
                } else {
                    Text(MatchInfoStatus.deadline.rawValue)
                        .matchTagStyle(tagType: MatchInfoStatus.deadline)
                }
            }
            .font(.system(size: 14))
            
            Spacer()
            
            // 추가: 조건부 x버튼
            if showDeleteButton{
                Button {
                    print("x버튼 탭")
                    isShowAlert = true
                } label: {
                    Image(systemName: "xmark")
                }
                .padding(.horizontal, 10)
                .foregroundStyle(Color.black)
                .alert("삭제할까요?", isPresented: $isShowAlert) {
                    Button("취소"){
                        isShowAlert = false
                    }
                    Button("삭제"){}
                }
            }
        }
    }
}
