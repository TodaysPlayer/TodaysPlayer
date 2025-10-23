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
    var currentMatch: Match
    
    // MARK: - State
    var userApply: Apply? = nil
    var isLoading: Bool = false
    
    // MARK: - Gender Validation State
    var showGenderAlert: Bool = false
    var genderAlertMessage: String = ""
    
    // MARK: - Initalization
    init(match: Match) {
        self.match = match
        self.currentMatch = match
    }
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
        
        if !currentMatch.isRecruiting {
            return currentMatch.buttonTitle  // "모집마감", "경기확정" 등
        }
        
        guard let status = userApplyStatus else {
            return "신청하기"
        }
        
        switch status {
        case .standby:
            return "수락 대기중"
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
        
        if !currentMatch.isRecruiting {
            return false
        }
        
        // 신청 안한 경우만 신청 가능
        return userApplyStatus == nil
    }
    
    /// 버튼 배경색
    var buttonBackgroundColor: Color {
        if isMyMatch {
            return .blue
        }
        
        if !currentMatch.isRecruiting {
            return .gray
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
    
    // 최신 매치 정보 가져오기
    func fetchLatestMatch() async {
        do {
            guard let updatedMatch = try await FirestoreManager.shared.getDocument(
                collection: "matches",
                documentId: match.id,
                as: Match.self
            ) else { return }
            
            self.currentMatch = updatedMatch
            print("✅ 매치 정보 갱신: \(updatedMatch.status), 신청인원: \(updatedMatch.appliedParticipantsCount)/\(updatedMatch.maxParticipants)")
        } catch {
            print("⚠️ 매치 정보 갱신 실패: \(error)")
        }
    }
    
    func refreshUserApplyStatus() async {
        // ✅ 매치 정보도 함께 갱신
        await fetchLatestMatch()
        
        let userId = AuthHelper.currentUserId
        
        // Apply 문서 재조회
        let allApplies = await repository.fetchParticipants(matchId: match.id)
        userApply = allApplies.first { $0.userId == userId }
        
        print("✅ 신청 상태 새로고침: \(userApply?.status ?? "없음")")
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
    
    // MARK: - Gender Validation
    
    /// 성별 제한 체크
    func canUserApply() -> Bool {
        // 본인 매치거나 혼성 경기면 항상 가능
        if isMyMatch || match.gender == GenderType.mixed.rawValue {
            return true
        }
        
        guard let userGender = AuthHelper.currentUser?.gender else {
            print("❌ 사용자 성별 정보 없음")
            return false
        }
        
        // Match의 영어 성별을 한글로 변환해서 비교
        let matchGenderKorean = convertGenderToKorean(match.gender)
        
        print("🔍 성별 체크 - Match: \(match.gender) (\(matchGenderKorean)) vs User: \(userGender)")
        
        return matchGenderKorean == userGender
    }
    
    /// 영어 성별 -> 한글 변환
    private func convertGenderToKorean(_ gender: String) -> String {
        switch gender {
        case GenderType.male.rawValue:
            return "남성"
        case GenderType.female.rawValue:
            return "여성"
        case GenderType.mixed.rawValue:
            return "혼성"
        default:
            return gender
        }
    }
    
    /// 성별 불일치 시 Alert 메시지 생성
    func getGenderMismatchMessage() -> String {
        switch match.gender {
        case GenderType.male.rawValue:
            return "남성 전용 경기입니다.\n다른 매치를 구경해보세요!"
        case GenderType.female.rawValue:
            return "여성 전용 경기입니다.\n다른 매치를 구경해보세요!"
        default:
            return "신청할 수 없습니다."
        }
    }
    
    /// 신청 가능 여부 체크 후 액션 실행
    func handleApplyButtonTap() {
        if canUserApply() {
            // 성별 제한 통과 - 네비게이션 진행
            print("성별 체크 통과 - 신청 화면으로 이동")
            return
        } else {
            // 성별 제한 걸림 - Alert 표시
            print("성별 체크 실패 - Alert 표시")
            genderAlertMessage = getGenderMismatchMessage()
            showGenderAlert = true
        }
    }
}
