//
//  ParticipantListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//


import Foundation

@Observable
final class ParticipantListViewModel {
    let match: Match
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
    
    init(match: Match){
        self.match = match
    
        Task { await fetchInitialDatas() }
    }
    
    func fetchInitialDatas() async {
        let applyDatas = await repository.fetchParticipants(matchId: match.id)
        participantDatas = applyDatas
        displayedApplies = participantDatas.filter({ $0.applyStatusEnum == selectedStatus })
    }
    
    /// 세그먼트 누른 타입대로 신청자 정보 보여주기
    func fetchParticipantDatas(type: String){
        guard let type = ApplyStatus(rawValue: type) else { return }
        // apply로 모델 변경
        
        selectedStatus = type
        displayedApplies = []
        
        switch type {
        case .standby: displayedApplies = standbyApplies
        case .accepted: displayedApplies = acceptedApplies
        case .rejected: displayedApplies = rejectedApplies
        default: displayedApplies = standbyApplies
        }
    }
    
    // MARK: 신청자 수락 및 거절
    
    
    /// 신청 수락 / 거절
    func managementAppliedStatus(
        status: ApplyStatus,
        rejectCase: RejectCase? = nil,
        _ reason: String? = ""
    ) async  {
        guard !(match.maxParticipants == acceptedApplies.count),
              let info = selectedPersonInfo else {
            toastManager.show(.maxiumParticipants)
            return
        }
        
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
                    matchId: match.id
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
        
        // 최대인원수가 되었을 때 나머지 인원들 거절하기
        if match.maxParticipants == acceptedApplies.count {
            await rejectRemainingStandbyApplies()
        }
    }
    
    // 나머지 인원 자동거절
    private func rejectRemainingStandbyApplies() async {
        let remainingStandby = standbyApplies
        
        // 로컬 데이터 즉시 갱신
        participantDatas.removeAll { apply in
            remainingStandby.contains(where: { $0.userId == apply.userId })
        }
        
        let rejectedApplies = remainingStandby.map { standby in
            Apply(
                id: standby.id,
                matchId: standby.matchId,
                userId: standby.userId,
                userNickname: standby.userNickname,
                userSkillLevel: standby.userSkillLevel,
                position: standby.position,
                participantCount: standby.participantCount,
                message: standby.message,
                status: ApplyStatus.rejected.rawValue,
                rejectionReason: "정원 마감으로 인한 자동 거절",
                appliedAt: standby.appliedAt,
                processedAt: standby.processedAt,
                userRate: standby.userRate
            )
        }
        
        participantDatas.append(contentsOf: rejectedApplies)
        
        await withTaskGroup(of: Void.self) { group in
            for standby in remainingStandby {
                group.addTask {
                    await self.repository.updateParticipant(
                        applyStatus: .rejected,
                        applyInfo: standby,
                        rejectReason: "정원 마감으로 인한 자동 거절",
                        matchId: self.match.id
                    )
                }
            }
        }
    }
    
    
    /// 평균 평점 계산
    func avgRating(for participant: Apply) -> Double {
        let rate = participant.userRate
        guard rate.totalRatingCount > 0 else { return 0.0 }
        let total = rate.appointmentSum + rate.mannerSum + rate.teamWorkSum
        return total / Double(rate.totalRatingCount)
    }
    
}
