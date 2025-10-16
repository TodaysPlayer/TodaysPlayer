//
//  ParticipantListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//


import Foundation

@Observable
final class ParticipantListViewModel {
    let matchID: String
    var participantDatas: [Apply] = []
    var standbyApplies: [Apply] { participantDatas.filter { $0.applyStatusEnum == .standby }}
    var acceptedApplies: [Apply] { participantDatas.filter { $0.applyStatusEnum == .accepted }}
    var rejectedApplies: [Apply] { participantDatas.filter { $0.applyStatusEnum == .rejected }}
    var displayedApplies: [Apply] = []
    
    var selectedStatus: ApplyStatus = .standby
    var selectedPersonInfo: Apply? = nil
    
    var isShowAcceptAlert: Bool = false
    var isShowRejectSheet: Bool = false
    
    var toastManager: ToastMessageManager = ToastMessageManager()
    private let repository: ParticipantRepository = ParticipantRepository()
    
    init(matchID: String){
        self.matchID = matchID
        
        Task {
          let applyDatas = await repository.fetchParticipants(matchId: matchID)
          participantDatas = applyDatas
          displayedApplies = participantDatas.filter({ $0.applyStatusEnum == .standby })
        }
    }
    
    /// 세그먼트 누른 타입대로 신청자 정보 보여주기
    func fetchParticipantDatas(type: String){
        guard let type = ApplyStatus(rawValue: type) else { return }
        // apply로 모델 변경

        displayedApplies = []
        
        switch type {
        case .standby: displayedApplies = standbyApplies
        case .accepted: displayedApplies = acceptedApplies
        case .rejected: displayedApplies = rejectedApplies
        default: displayedApplies = standbyApplies
        }
    }
    
    /// 신청 수락 / 거절
    func managementAppliedStatus(
        status: ApplyStatus,
        rejectCase: RejectCase? = nil,
        _ reason: String? = ""
    )  {
        guard let info = selectedPersonInfo else { return }
        
        // 기존 데이터 항목에서 제거
        participantDatas.removeAll { $0.userId == info.userId }
        displayedApplies.removeAll { $0.userId == info.userId }
        
        // 거절 시 이유
        let rejectionReason = rejectCase == .etc ? reason : rejectCase?.title
        
        Task {
            await repository
                .updateParticipant(
                    applyStatus: status,
                    applyInfo: info,
                    rejectReason: rejectionReason,
                    matchId: matchID
                )
        }
        
        // 새로운 데이터 항목 만들어주기
        let modifiedApply = Apply(
            id: info.id,
            matchId: info.matchId,
            userId: info.userId,
            userNickname: info.userNickname,
            userSkillLevel: info.userSkillLevel,
            position: info.position,
            participantCount: info.participantCount,
            message: info.message,
            status: ApplyStatusConverter.toString(from: status),
            rejectionReason: rejectionReason,
            appliedAt: info.appliedAt,
            processedAt: info.processedAt,
            userRate: info.userRate
        )
        
        participantDatas.append(modifiedApply)
    }
    
    /// 평균 평점 계산
    func avgRating(for participant: Apply) -> Double {
        let rate = participant.userRate
        guard rate.totalRatingCount > 0 else { return 0.0 }
        let total = rate.appointmentSum + rate.mannerSum + rate.teamWorkSum
        return total / Double(rate.totalRatingCount)
    }
    
}
