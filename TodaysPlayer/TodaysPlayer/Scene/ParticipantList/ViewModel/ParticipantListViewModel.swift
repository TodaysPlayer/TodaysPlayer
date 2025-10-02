//
//  ParticipantListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//


import Foundation

@Observable
final class ParticipantListViewModel {
    var participantDatas: [ParticipantEntity]
    
    var selectedStatus: ApplyStatus = .standby
    var selectedPersonInfo: ParticipantEntity? = nil
    
    var isShowAcceptAlert: Bool = false
    var isShowRejectSheet: Bool = false
    
    var toastManager: ToastMessageManager = ToastMessageManager()
    
    init(){
        self.participantDatas = mockParticipants.filter { $0.status == .standby }
    }
    
    /// 신청자 정보 가져오기
    func fetchParticipantDatas(status: ApplyStatus){
        participantDatas = mockParticipants.filter { $0.status == status }
    }
    
    /// 신청 수락 / 거절
    func managementAppliedStatus(
        status: ApplyStatus,
        rejectCase: RejectCase? = nil,
        _ reason: String? = ""
    ){
        guard let info = selectedPersonInfo else { return }
        switch status {
        case .accepted:
            participantDatas.removeAll(where: { $0.userName == info.userName })
            
            if let index = mockParticipants.firstIndex(where: { $0.userName == info.userName }) {
                mockParticipants[index].status = .accepted
            }
            
        case .rejected:
            participantDatas.removeAll(where: { $0.userName == info.userName })
            
            if let index = mockParticipants.firstIndex(where: { $0.userName == info.userName }) {
                mockParticipants[index].status = .rejected
                mockParticipants[index].rejectionReason = reason == "" ? rejectCase?.title : reason
            }
            
        default: return
        }
    }
}
