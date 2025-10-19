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
    // 필터링된 경기 데이터
    var appliedMatches: [Match] = []
    var recruitingMatches: [Match] = []
    var finishedMatches: [Match] = []
    
    // 화면에 보여줄 경기 데이터
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

    private let userId: String = "9uHP3cOHe8T2xwxS9lx"
    private var lastAppliedSnapshot: DocumentSnapshot?
    private var lastRecruitingSnapshot: DocumentSnapshot?
    private let pageSize = 5
    private let debounceDelay: UInt64 = 300_000_000
    private let repository = MatchRepository()

    init(){
        Task { await loadMoreMatches() }
    }
    
    // MARK: 세그먼트에 따라 경기 필터링
    // - 신청한 경기, 내가 모집중인 경기, 종료된 경기

    /// 필터링 버튼 설정
    func fetchFilteringButtonTitle(selectedType: String) {
        guard let type = PostedMatchCase(rawValue: selectedType) else { return }
        postedMatchCase = type
        lastAppliedSnapshot = nil
        lastRecruitingSnapshot = nil
        hasMore = true
        displayedMatches = []

        switch type {
        case .appliedMatch:
            filteringButtonTypes = MatchFilter.appliedCases
            selectedFilterButton = .applied(.all)
        case .myRecruitingMatch:
            filteringButtonTypes = []
        case .finishedMatch:
            filteringButtonTypes = MatchFilter.finishedCases
            selectedFilterButton = .finished(.all)
        default: filteringButtonTypes = []
        }

        // 버튼에 맞는 매치 가져오기
        Task { await loadMoreMatches() }
    }
    
    
    /// 경기 종류에 따라 보여지는 경기 변경
    /// - 신청한 경기, 내가 모집중인 경기, 종료된 경기
    private func updateDisplayedMatches() {
        switch postedMatchCase {
        case .appliedMatch:         displayedMatches = appliedMatches
        case .myRecruitingMatch:    displayedMatches = recruitingMatches
        case .finishedMatch:        displayedMatches = finishedMatches
        default:                    displayedMatches = []
        }
    }
    
    // MARK: 필터링 버튼에 따른 경기 보여주기
    // 신청한 경기 - 전체, 확정된 경기, 대기중인 경기, 거절된 경기
    // 내가 모집중인 경기
    // 종료된 경기 - 전체, 참여한 경기, 내가 모집한 경기


    // MARK: 경기 데이터 가져오기

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
            case .appliedMatch: // 신청한 경기의 경우
                let page = try await repository.fetchAppliedMatchesPage(
                    with: userId,
                    pageSize: pageSize,
                    after: lastAppliedSnapshot
                )
                nextMatches = page.matches
                lastAppliedSnapshot = page.lastDocument
                fetchedCount = page.fetchedCount
            case .myRecruitingMatch:  // 내가 모집중인 경기의 경우
                let page = try await repository.fetchRecruitingMatchesPage(
                    with: userId,
                    pageSize: pageSize,
                    after: lastRecruitingSnapshot
                )
                nextMatches = page.matches
                lastRecruitingSnapshot = page.lastDocument
                fetchedCount = page.fetchedCount
            case .finishedMatch:    // 종료된 경기의 경우
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


    // MARK: UI 표시를 위한 함수
    
    private func filteringRejectReason(status: String) -> String {
        return status
            .replacingOccurrences(of: "rejected", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getUserApplyStatus(appliedMatch: Match) -> (String, String, ApplyStatus) {
        // 내가 신청한 경기에 대한 정보를 받음
        guard let status = appliedMatch.participants[userId] else {
            return (userId, "", .standby)
        }
        
        let convertedStatus = ApplyStatusConverter.toStatus(from: status)
        // oncvertedStatus가 .standby 거나 .accepted 면 거절사유가 없음 .rejected면 거절사유가 잇음
        let rejectReason = convertedStatus == .rejected ? filteringRejectReason(status: status) : ""
        print("매치아이디:\(appliedMatch.id)")
        print("\(userId), 거절사유 혹은 상태 \(status)")
        return (userId, rejectReason, convertedStatus)
    }
    
    func getTagInfomation(with match: Match) -> (String, ApplyStatus, Int) {
        
        let matchType = match.convertMatchType(type: match.matchType).rawValue
        let (_, _, applyStatus) = getUserApplyStatus(appliedMatch: match)
        let participants = match.participants.map { (_, value: String) in
            value != "rejected"
        }.count
        let leftPersonCount = match.maxParticipants - participants

        return (matchType, applyStatus, leftPersonCount)
    }
}
