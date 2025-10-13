//
//  MatchListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI
import Combine

@Observable
final class MatchListViewModel {
    var appliedMatches: [Match] = []      // 내가 신청한 경기
    var recruitingMatches: [Match] = []   // 내가 모집 중인 경기
    var finishedMatches: [Match] = []     // 종료된 경기
    
    // 현재 선택된 타입에 따른 표시용 데이터
    var displayedMatches: [Match] = []
    
    // 매치 카테고리 타이틀
    var myMatchSegmentTitles: [String]
    
    // 필터버튼
    var filteringButtonTypes: [MatchFilter]
    var selectedFilterButton: MatchFilter = .applied(.all)
    
    // 로딩 상태
    var isLoading = false
    var hasMore = true
    
    var postedMatchCase: PostedMatchCase = .appliedMatch
    
    private let userId: String = "9uHP3cOHe8T2xwxS9Ifx"
    private var lastFetchedMatch: Match?
    private let pageSize = 10
    
    init() {
        self.myMatchSegmentTitles = PostedMatchCase.allCases
            .map { $0.rawValue }
            .filter { $0 != PostedMatchCase.allMatches.rawValue }
        
        self.filteringButtonTypes = AppliedMatch.allCases.map { MatchFilter.applied($0) }
    }
    
    @MainActor
    func loadInitialMatches() async {
        isLoading = false
        lastFetchedMatch = nil
        hasMore = true
        await loadMoreMatches()
        isLoading = true
    }
    
    @MainActor
    func loadMoreMatches() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        
        do {
            // 내가 신청한 매치 가져오기
//            var queryApplies: [Apply] = try await FirestoreManager.shared
//                .queryDocuments(
//                    collection: "apply",
//                    where: "applicantId",
//                    isEqualTo: userId,
//                    as: Apply.self
//                )
//            
//            // 이미 불러온 이후 데이터 제외
//            if let lastMatch = lastFetchedMatch {
//                if let index = queryApplies.firstIndex(where: { $0.matchId == lastMatch.id }) {
//                    queryApplies = Array(queryApplies.suffix(from: index + 1))
//                }
//            }
//            
//            let nextChunk = Array(queryApplies.prefix(pageSize))
//            if nextChunk.isEmpty {
//                hasMore = false
//                isLoading = false
//                return
//            }
            
            // 요게 내가 신청한 애들
//            for apply in nextChunk {
//                guard let match = try await FirestoreManager.shared
//                    .getDocument(
//                        collection: "matches",
//                        documentId: apply.matchId,
//                        as: Match.self) else { return }
//                    appliedMatches.append(match)
//                
//            }
//            
     
            // 내가 모집중인 애들
            let match1 = try await FirestoreManager.shared.queryDocuments(
                collection: "matches",
                where: "organizerId",
                isEqualTo: userId,
                as: Match.self
            )
            
            recruitingMatches.append(contentsOf: match1)
            // 내가 신청한 애들 , 내가 모집중인 애들 불러오기
            // 거기서 필터링
            // 없으면 다시 불러오기
//
//            // 죵료된 애들 - 내가 모집한 애들, 내가 신청한 애들 둘 다 포함
//            let matches2 = try await FirestoreManager.shared.mutipleQueryDocuments(
//                collection: "matches",
//                conditions: [
//                    ("organizerId", .isEqualTo, userId),
//                    ("status", .isEqualTo, "finished")
//                ], as: Match.self)
//            
//            finishedMatches.append(contentsOf: matches2)
//            
//            lastFetchedMatch = newMatches.last
//            hasMore = newMatches.count == pageSize
            
            // 지금 이 Matches가 내가 신청한 애들(내가 모집중 포함)
//            print("종료된 애들:\(matches2)")
            print("내가 모집중인 애들:\(recruitingMatches)")
//            print("신청한 애들:\(appliedMatches)")
            
            
        } catch {
            print("데이터 불러오기 실패: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchMatchListDatas(selectedType: String) {
        guard let type = PostedMatchCase(rawValue: selectedType) else { return }
        postedMatchCase = type
        switch type {
        case .appliedMatch:
            filteringButtonTypes = MatchFilter.appliedCases
        case .myRecruitingMatch:
            filteringButtonTypes = []
        case .finishedMatch:
            filteringButtonTypes = MatchFilter.finishedCases
        default: break
        }
    }
}
