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
    
    init(){
        self.participantDatas = mockParticipants.filter { $0.status == .standby }
    }
    
    /// 신청자 정보 가져오기
    func fetchParticipantDatas(status: ApplyStatus){
        participantDatas = mockParticipants.filter { $0.status == status }
    }
    
    
    /// 신청 수락 / 거절
    func managementAppliedStatus(_ info: ParticipantEntity, _ status: ApplyStatus){
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
            }
            
        default: return
        }
    }
}
