//
//  MatchListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

@Observable
final class MatchListViewModel {
    var appliedMatches: [Match] = []
    var recruitingMatches: [Match] = []
    var finishedMatches: [Match] = []
    var displayedMatches: [Match] = []
    
    var filteringButtonTypes: [MatchFilter] = []
    var selectedFilterButton: MatchFilter = .applied(.all)
    
    var isLoading: Bool = false
    var hasMore: Bool = true

    var myMatchSegmentTitles: [String] = PostedMatchCase.allCases
        .map { $0.rawValue }
        .filter { $0 != PostedMatchCase.allMatches.rawValue }

    var postedMatchCase: PostedMatchCase = .appliedMatch {
        didSet { updateDisplayedMatches() }
    }

    private let userId: String = "9uHP3cOHe8T2xwxS9lfx"
    private var lastAppliedSnapshot: DocumentSnapshot?
    private var lastRecruitingSnapshot: DocumentSnapshot?
    private let pageSize = 5
    private let debounceDelay: UInt64 = 300_000_000
    private let repository = MatchRepository()

    init(){
        Task { await loadMoreMatches() }
    }
    
    
    /// 필터링 버튼 설정
    func fetchFilteringButtonTitle(selectedType: String) {
        guard let type = PostedMatchCase(rawValue: selectedType) else { return }
        postedMatchCase = type
        lastAppliedSnapshot = nil
        lastRecruitingSnapshot = nil
        hasMore = true
        displayedMatches = []

        switch type {
        case .appliedMatch: filteringButtonTypes = MatchFilter.appliedCases
        case .myRecruitingMatch: filteringButtonTypes = []
        case .finishedMatch: filteringButtonTypes = MatchFilter.finishedCases
        default: filteringButtonTypes = []
        }

        // 버튼에 맞는 매치 가져오기
        Task { await loadMoreMatches() }
    }

    @MainActor
    func loadMoreMatches() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: debounceDelay)

        do {
            let nextMatches: [Match]
            var fetchedCount: Int = 0
            switch postedMatchCase {
            case .appliedMatch:
                let page = try await repository.fetchAppliedMatchesPage(
                    with: userId,
                    pageSize: pageSize,
                    after: lastAppliedSnapshot
                )
                nextMatches = page.matches
                lastAppliedSnapshot = page.lastDocument
                fetchedCount = page.fetchedCount
            case .myRecruitingMatch:
                let page = try await repository.fetchRecruitingMatchesPage(
                    with: userId,
                    pageSize: pageSize,
                    after: lastRecruitingSnapshot
                )
                nextMatches = page.matches
                lastRecruitingSnapshot = page.lastDocument
                fetchedCount = page.fetchedCount
            case .finishedMatch:
                nextMatches = []
                fetchedCount = 0
            default:
                nextMatches = []
                fetchedCount = 0
            }

            let existing = Set(displayedMatches.map { $0.id })
            let deduped = nextMatches.filter { !existing.contains($0.id) }
            displayedMatches.append(contentsOf: deduped)
            hasMore = fetchedCount == pageSize
        } catch {
            print("추가 데이터 로드 실패: \(error)")
            hasMore = false
        }
    }

    private func updateDisplayedMatches() {
        switch postedMatchCase {
        case .appliedMatch:         displayedMatches = appliedMatches
        case .myRecruitingMatch:    displayedMatches = recruitingMatches
        case .finishedMatch:        displayedMatches = finishedMatches
        default:                    displayedMatches = []
        }
    }
}
