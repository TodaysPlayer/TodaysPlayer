
//
//  ParticipantRepository.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/15/25.
//

import Foundation

final class ParticipantRepository {
    
    
    // 매치 아이디를 가지고 apply에서 매치 아이디랑 일치하는 애들 가져오고 데이터 표시
    
    /// 매치 신청한 유저정보 가져오기
    func fetchParticipants(matchId: String) async -> [Apply] {
        do {
            let applyDatas = try await FirestoreManager.shared
                .queryDocuments(
                    collection: "apply",
                    where: "matchId",
                    isEqualTo: matchId,
                    as: Apply.self
                )
            print(applyDatas)
            return applyDatas
        }catch {
            print("참여자 정보를 불러오지 못함\(error.localizedDescription)")
            return []
        }
    }
    
    
    // 수락 거절 시 매치 데이터에 참여자 항목 수정, 신청 상태변경 (매치데이터에 참여자 정보도 수정)
    func updateParticipant(
        applyStatus: ApplyStatus,
        applyInfo: Apply,
        match: Match
    ) async -> Bool {
        do {
            _ = try await FirestoreManager.shared
                .updateDocument(
                    collection: "matches",
                    documentId: match.id ,
                    data: ["participants.\(applyInfo.userId)": "pending"]
                )
            
            _ = try await FirestoreManager.shared
                .updateDocument(
                    collection: "apply",
                    documentId: applyInfo.id,
                    data: ["status" : ""]
                )
            
            // 네트워킹 처리를 다시 하는게 아니라 수정된 애를 반환하고 이미 가져왔던 애들 중 수정하는 방식으로?
            return true
        }catch {
            print("참여자 수락 / 거절에 실패함 \(error.localizedDescription)")
            return false
        }
    }
}
