
//
//  ParticipantRepository.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/15/25.
//

import Foundation

final class ParticipantRepository {
    
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
            return applyDatas
        }catch {
            print("참여자 정보를 불러오지 못함\(error.localizedDescription)")
            return []
        }
    }
    
    /// 경기 데이터의 신청자 상태변경
    private func updateApplyStatusInMatchData(
        matchId: String,
        applyStatus: String,
        applyInfo: Apply
    ) async throws {
        _ = try await FirestoreManager.shared
            .updateDocument(
                collection: "matches",
                documentId: matchId ,
                data: ["participants.\(applyInfo.userId)": applyStatus]
            )
    }
    
    
    /// 신청자의 신청상태변경
    private func updateApplyStatus(
        applyStatus: String,
        applyInfo: Apply,
        rejectReason: String
    ) async throws {
        _ = try await FirestoreManager.shared
            .updateDocument(
                collection: "apply",
                documentId: applyInfo.id,
                data: [
                    "status" : applyStatus,
                    "rejectionReason" : rejectReason
                ]
            )
    }
    
    // 매치 데이터에 참여자 항목 수정
    func updateParticipant(
        applyStatus: ApplyStatus,
        applyInfo: Apply,
        rejectReason: String? = nil,
        matchId: String
    ) async {
        let applyStatusString: String = ApplyStatusConverter.toString(from: applyStatus)
        
        do {
            try await withThrowingTaskGroup { group in
                group.addTask {
                    try await self.updateApplyStatus(
                        applyStatus: applyStatusString,
                        applyInfo: applyInfo,
                        rejectReason: rejectReason ?? ""
                    )
                }
                group.addTask {
                    try await self.updateApplyStatusInMatchData(
                        matchId: matchId,
                        applyStatus: applyStatusString,
                        applyInfo: applyInfo
                    )
                }
                
                try await group.waitForAll()
            }
            print("Firebase 데이터 업데이트 완료")
        }catch {
            print("Firebase 데이터 업데이트 실패: \(error.localizedDescription)")
        }
    }
}
