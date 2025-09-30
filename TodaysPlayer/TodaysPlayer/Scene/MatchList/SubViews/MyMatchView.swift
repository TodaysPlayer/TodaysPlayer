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
    var showDeleteButton: Bool = false // 추가: X 버튼 표시 여부
    var showApplyStatus: Bool = false // 추가: 신청 상태 표시 여부
    var showRejectionButton: Bool = false // 추가: 거절 사유 상태 표시 여부
    
    var body: some View {
        VStack(spacing: 20) {
            MyMatchTagView(
                matchInfo: matchInfo,
                showDeleteButton: showDeleteButton,
                showApplyStatus: showApplyStatus
            )
                    
            MyMatchInfoView(
                matchInfo: matchInfo,
                showRejectionButton: showRejectionButton
            )
        }
    }
}
