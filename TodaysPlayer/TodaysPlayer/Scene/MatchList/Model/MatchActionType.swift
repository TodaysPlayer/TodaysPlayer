//
//  MatchActionType.swift
//  TodaysPlayer
//
//  Created by 권소정 on 9/30/25.
//

import SwiftUI

// MARK: - 매칭 액션 버튼 타입
enum MatchActionType {
    case apply          // 참여신청하기
    case waiting        // 수락대기중
    case manage         // 참여인원 관리하기
    case finished       // 종료된 경기
    
    var title: String {
        switch self {
        case .apply:
            return "참여신청하기"
        case .waiting:
            return "수락대기중"
        case .manage:
            return "참여인원 관리하기"
        case .finished:
            return "종료된 경기"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .apply:
            return .green
        case .waiting, .finished:
            return .gray
        case .manage:
            return .blue
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .apply, .manage:
            return true
        case .waiting, .finished:
            return false
        }
    }
}

// MARK: - PostedMatchCase Extension
extension PostedMatchCase {
    var defaultActionType: MatchActionType {
        switch self {
        case .allMatches:
            return .apply          // 참여신청하기(소정)
            
        case .appliedMatch:
            return .waiting        // 용헌님: ApplyStatus 확인 후 분기 필요할것같아요
                                    // stanby, approved, rejected등 케이스별 처리
            
        case .myRecruitingMatch:
            return .manage         // 인원관리 화면 연결 필요
            
        case .finishedMatch:
            return .finished
        }
    }
}
