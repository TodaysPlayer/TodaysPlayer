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
    var isLoadingMore: Bool = false
    var showEndPulse: Bool = false

    var myMatchSegmentTitles: [String] = PostedMatchCase.allCases
        .map { $0.rawValue }
        .filter { $0 != PostedMatchCase.allMatches.rawValue }

    var postedMatchCase: PostedMatchCase = .appliedMatch {
        didSet { updateDisplayedMatches() }
    }

    private let userId: String = "9uHP3cOHe8T2xwxS9lx"
    private var lastAppliedSnapshot: DocumentSnapshot?
    private var lastRecruitingSnapshot: DocumentSnapshot?
    private let pageSize = 2
    private let debounceDelay: UInt64 = 300_000_000
    private let repository = MatchRepository()

    init(){
        Task { await loadInitialMatches() }
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
        Task { await loadInitialMatches() }
    }

    // 초기 로드
    @MainActor
    func loadInitialMatches() async {
        await loadMatches(reset: true)
    }

    @MainActor
    func loadMoreMatches() async {
        await loadMatches(reset: false)
    }

    // 통합 로더
    @MainActor
    func loadMatches(reset: Bool) async {
        if reset {
            guard !isLoading else { return }
            isLoading = true
        } else {
            guard !isLoading, !isLoadingMore, hasMore else { return }
            isLoadingMore = true
        }

        defer {
            if reset { isLoading = false } else { isLoadingMore = false }
        }

            try? await Task.sleep(nanoseconds: debounceDelay)
     
        do {
            if reset {
                lastAppliedSnapshot = nil
                lastRecruitingSnapshot = nil
                displayedMatches = []
                hasMore = true
            }

            let fetched: [Match]
            var fetchedCount: Int = 0
            switch postedMatchCase {
            case .appliedMatch:
                let page = try await repository.fetchAppliedMatchesPage(
                    with: userId,
                    pageSize: pageSize,
                    after: lastAppliedSnapshot
                )
                fetched = page.matches
                lastAppliedSnapshot = page.lastDocument
                fetchedCount = page.fetchedCount
            case .myRecruitingMatch:
                let page = try await repository.fetchRecruitingMatchesPage(
                    with: userId,
                    pageSize: pageSize,
                    after: lastRecruitingSnapshot
                )
                fetched = page.matches
                lastRecruitingSnapshot = page.lastDocument
                fetchedCount = page.fetchedCount
            case .finishedMatch:
                fetched = []
                fetchedCount = 0
            default:
                fetched = []
                fetchedCount = 0
            }

            if reset {
                var map: [String: Match] = [:]
                for m in fetched { map[m.id] = m }
                displayedMatches = Array(map.values)
            } else {
                let existing = Set(displayedMatches.map { $0.id })
                let deduped = fetched.filter { !existing.contains($0.id) }
                displayedMatches.append(contentsOf: deduped)
            }

            hasMore = fetchedCount == pageSize
        } catch {
            print("데이터 로드 실패: \(error)")
            hasMore = false
        }
    }

    @MainActor
    func pulseEndIndicator() async {
        guard !isLoading, !isLoadingMore, !hasMore, !showEndPulse else { return }
        showEndPulse = true
        defer { showEndPulse = false }
        try? await Task.sleep(nanoseconds: 600_000_000)
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
