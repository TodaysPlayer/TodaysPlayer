//
//  MyMatchListService.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/14/25.
//

import Foundation
import FirebaseFirestore

final class MatchRepository {
    private let db = Firestore.firestore()

    /// 모집중인 경기 조회 (최신 생성 순)
    func fetchRecruitingMatchesPage(
        with userId: String,
        pageSize: Int,
        after lastDocument: DocumentSnapshot?
    ) async throws -> (matches: [Match], lastDocument: DocumentSnapshot?, fetchedCount: Int) {
        var query: Query = db
            .collection("matches")
            .whereField("organizerId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: pageSize)

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        let snapshot = try await query.getDocuments()
        let decoder = Firestore.Decoder()
        let matches: [Match] = snapshot.documents.compactMap { doc in
            decoder.userInfo[Match.documentIdKey] = doc.documentID
            return try? doc.data(as: Match.self, decoder: decoder)
        }

        let nextCursor = snapshot.documents.last
        return (matches, nextCursor, snapshot.documents.count)
    }

    /// 신청한 경기 조회 (최신 신청 순)
    func fetchAppliedMatchesPage(
        with userId: String,
        pageSize: Int,
        after lastDocument: DocumentSnapshot?
    ) async throws -> (matches: [Match], lastDocument: DocumentSnapshot?, fetchedCount: Int) {
        var query: Query = db
            .collection("apply")
            .whereField("userId", isEqualTo: userId)
            .order(by: "appliedAt", descending: true)
            .limit(to: pageSize)

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        let applySnapshot = try await query.getDocuments()
        let appliesAll: [Apply] = applySnapshot.documents.compactMap { doc in
            return try? doc.data(as: Apply.self)
        }
        var uniqueByMatchId: [String: Apply] = [:]
        for apply in appliesAll { uniqueByMatchId[apply.matchId] = apply }
        let applies = Array(uniqueByMatchId.values)

        var matches: [Match] = []
        for apply in applies {
            if let match = try await FirestoreManager.shared.getDocument(
                collection: "matches",
                documentId: apply.matchId,
                as: Match.self
            ) {
                matches.append(match)
            }
        }

        let nextCursor = applySnapshot.documents.last
        return (matches, nextCursor, applySnapshot.documents.count)
    }

    
    func fetchFinishedMatches(with userId: String) async throws -> [Match] {
        let query = db.collection("matches")
            .whereFilter(
                .orFilter([
                    .whereField("participants.\(userId)", isEqualTo: userId),
                    .whereField("organizerId", isEqualTo: userId)
                ])
            )
            .whereField("status", isEqualTo: "finished")
        
        let snapshot = try await query.getDocuments()
        
        let matches: [Match] = snapshot.documents.compactMap { doc in
            try? doc.data(as: Match.self)
        }
        
        return matches
    }
    
    
    /// 경기 종료하기
    /// - Parameters:
    ///   - withRate: 평가가 완료된 경우(true), 평가가 완료되지 않은 경우 (false)
    func eidtMatchStatusToFinish(matchId: String, withRate: Bool = false) async {
        let data: [String: Any] = withRate
            ? ["status": "finished", "rating": 1.0]
            : ["status": "finished"]
        
        do {
            try await FirestoreManager.shared
                .updateDocument(
                    collection: "matches",
                    documentId: matchId,
                    data: data
                )
        } catch {
            print("경기데이터 업데이트에 실패했습니다: \(error.localizedDescription)")
        }
    }
}
