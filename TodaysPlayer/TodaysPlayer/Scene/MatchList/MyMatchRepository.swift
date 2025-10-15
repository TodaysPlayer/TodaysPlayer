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

    /// 모집중인 경기 페이지네이션 조회 (최신 생성 순)
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

    /// 신청한 경기 페이지네이션 조회 (신청 최신 순)
    func fetchAppliedMatchesPage(
        with userId: String,
        pageSize: Int,
        after lastDocument: DocumentSnapshot?
    ) async throws -> (matches: [Match], lastDocument: DocumentSnapshot?, fetchedCount: Int) {
        var query: Query = db
            .collection("apply")
            .whereField("applicantId", isEqualTo: userId)
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
}
