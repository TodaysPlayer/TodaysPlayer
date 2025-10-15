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
        }
    }
    
    /// 신청자 정보 가져오기
    func fetchParticipantDatas(type: String){
        guard let type = ApplyStatus(rawValue: type) else { return }
        // apply로 모델 변경
    }
    
    /// 신청 수락 / 거절
    func managementAppliedStatus(
        status: ApplyStatus,
        rejectCase: RejectCase? = nil,
        _ reason: String? = ""
    ){
        guard let info = selectedPersonInfo else { return }
//        switch status {
//        case .accepted:
////            participantDatas.removeAll(where: { $0.userName == info.userName })
////            
////            if let index = mockParticipants.firstIndex(where: { $0.userName == info.userName }) {
////                mockParticipants[index].status = .accepted
////            }
//            
//        case .rejected:
////            participantDatas.removeAll(where: { $0.userName == info.userName })
////            
////            if let index = mockParticipants.firstIndex(where: { $0.userName == info.userName }) {
////                mockParticipants[index].status = .rejected
////                mockParticipants[index].rejectionReason = reason == "" ? rejectCase?.title : reason
////            }
//            
//        default: return
//        }
    }
}
