//
//  MatchDetailViewModel.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/17/25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class MatchDetailViewModel {
    // MARK: - Properties
    let match: Match
    private let repository = ParticipantRepository()
    
    // MARK: - State
    var userApply: Apply? = nil
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    /// Match.participants에서 빠르게 상태 확인
    var quickUserStatus: String? {
        match.participants[AuthHelper.currentUserId]
    }
    
    /// Apply 문서에서 상세 상태 확인
    var detailedUserStatus: ApplyStatus? {
        userApply?.applyStatusEnum
    }
    
    /// 최종 사용자 신청 상태
    var userApplyStatus: ApplyStatus? {
        // 1차: Match.participants에서 빠르게 확인
        if let quickStatus = quickUserStatus {
            return ApplyStatusConverter.toStatus(from: quickStatus)
        }
        
        // 2차: Apply 문서가 로드되었다면 그것 사용
        return detailedUserStatus
    }
    
    /// 본인이 작성한 매치인지 확인
    var isMyMatch: Bool {
        match.organizerId == AuthHelper.currentUserId
    }
    
    /// 버튼 타이틀
    var buttonTitle: String {
        if isMyMatch {
            return "참여자 관리"
        }
        
        guard let status = userApplyStatus else {
            return "신청하기"
        }
        
        switch status {
        case .standby:
            return "대기중"
        case .accepted:
            return "참여 확정"
        case .rejected:
            return "거절됨"
        default:
            return "신청하기"
        }
    }
    
    /// 버튼 활성화 여부
    var isButtonEnabled: Bool {
        if isMyMatch {
            return true // 주최자는 항상 참여자 관리 가능
        }
        
        // 신청 안한 경우만 신청 가능
        return userApplyStatus == nil
    }
    
    /// 버튼 배경색
    var buttonBackgroundColor: Color {
        if isMyMatch {
            return .blue
        }
        
        guard let status = userApplyStatus else {
            return .green // 신청하기
        }
        
        switch status {
        case .standby:
            return .orange
        case .accepted:
            return .blue
        case .rejected:
            return .gray
        default:
            return .green
        }
    }
    
    // MARK: - Initialization
    init(match: Match) {
        self.match = match
    }
    
    // MARK: - Methods
    
    /// Apply 문서의 상세 정보 가져오기 (거절 사유 등이 필요할 때)
    func fetchDetailedApply() async {
        isLoading = true
        defer { isLoading = false }
        
        let userId = AuthHelper.currentUserId
        
        let allApplies = await repository.fetchParticipants(matchId: match.id)
            
        // 현재 사용자의 Apply 필터링
        userApply = allApplies.first { $0.userId == userId }
        
        print("✅ Apply 상세 조회 완료: \(userApply?.status ?? "없음")")
    }
}
