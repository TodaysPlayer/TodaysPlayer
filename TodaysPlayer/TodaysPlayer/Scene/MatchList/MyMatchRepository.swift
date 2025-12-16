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
    
    /// 종료된 경기 누적
    private var finishedMatches: [Match] = []

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

        // 종료 처리 필요: 시작일이 지난 경기
        let now = Date()
        let newlyFinished = matches.filter { $0.dateTime < now && $0.status != "finished" }

        // 로컬 상태 먼저 갱신
        finishedMatches.append(contentsOf: newlyFinished.filter { !finishedMatches.contains($0) })
        let validMatches = matches.filter { $0.status != "finished" && $0.dateTime > now }

        // 서버에 병렬로 상태 업데이트
        await withTaskGroup(of: Void.self) { group in
            for match in newlyFinished {
                group.addTask { await self.eidtMatchStatusToFinish(matchId: match.id) }
            }
            await group.waitForAll()
        }

        return (validMatches, snapshot.documents.last, snapshot.documents.count)
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
    /// 종료된 경기 조회
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
        let fetchedMatches = snapshot.documents.compactMap { doc in
            try? doc.data(as: Match.self)
        }

        // 로컬 finishedMatches와 합치되 중복 제거
        let allFinished = fetchedMatches + finishedMatches
        var uniqueFinished: [String: Match] = [:]
        for match in allFinished {
            uniqueFinished[match.id] = match
        }

        return Array(uniqueFinished.values)
    }

    /// 경기 종료 처리
    func eidtMatchStatusToFinish(matchId: String, withRate: Bool = false) async {
        let data: [String: Any] = withRate
            ? ["status": "finished", "rating": 1.0, "updatedAt": Timestamp(date: Date())]
            : ["status": "finished", "updatedAt": Timestamp(date: Date())]

        do {
            try await FirestoreManager.shared
                .updateDocument(collection: "matches", documentId: matchId, data: data)
        } catch {
            print("경기데이터 업데이트에 실패했습니다: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 달력용: 모든 경기 가져오기 (기존 메서드 활용)
    
    /// 달력용: 신청한 모든 경기 조회 (페이지네이션 반복 호출)
    func fetchAllAppliedMatches(userId: String) async throws -> [Match] {
        var allMatches: [Match] = []
        var lastDoc: DocumentSnapshot? = nil
        var shouldContinue = true
        
        while shouldContinue {
            let result = try await fetchAppliedMatchesPage(
                with: userId,
                pageSize: 100,
                after: lastDoc
            )
            
            allMatches.append(contentsOf: result.matches)
            lastDoc = result.lastDocument
            
            // 더 이상 데이터가 없으면 중단
            shouldContinue = result.fetchedCount >= 100
        }
        
        return allMatches
    }
    
    /// 달력용: 모집중인 모든 경기 조회 (페이지네이션 반복 호출)
    func fetchAllRecruitingMatches(userId: String) async throws -> [Match] {
        var allMatches: [Match] = []
        var lastDoc: DocumentSnapshot? = nil
        var shouldContinue = true
        
        while shouldContinue {
            let result = try await fetchRecruitingMatchesPage(
                with: userId,
                pageSize: 100,
                after: lastDoc
            )
            
            allMatches.append(contentsOf: result.matches)
            lastDoc = result.lastDocument
            
            shouldContinue = result.fetchedCount >= 100
        }
        
        return allMatches
    }
    
    /// 달력용: 날짜 범위로 필터링된 경기 반환
    func fetchMatchesForCalendar(
        userId: String,
        startDate: Date,
        endDate: Date
    ) async throws -> (applied: [Match], recruiting: [Match], finished: [Match]) {
        // 기존 메서드들을 병렬로 호출
        async let appliedMatches = fetchAllAppliedMatches(userId: userId)
        async let recruitingMatches = fetchAllRecruitingMatches(userId: userId)
        async let finishedMatches = fetchFinishedMatches(with: userId)
        
        let (applied, recruiting, finished) = try await (appliedMatches, recruitingMatches, finishedMatches)
        
        // 날짜 범위로 필터링
        let filteredApplied = applied.filter { $0.dateTime >= startDate && $0.dateTime < endDate }
        let filteredRecruiting = recruiting.filter { $0.dateTime >= startDate && $0.dateTime < endDate }
        let filteredFinished = finished.filter { $0.dateTime >= startDate && $0.dateTime < endDate }
        
        return (filteredApplied, filteredRecruiting, filteredFinished)
    }
}
