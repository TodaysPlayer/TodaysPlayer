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
    
    var filteringButtonTypes: [MatchFilter] = MatchFilter.appliedCases
    var selectedFilterButton: MatchFilter = .applied(.all) {
        didSet {
            print(selectedFilterButton)
            filteringButtonTapped(selectedFilterButton)
        }
    }
    
    
    var isLoading: Bool = false
    var hasMore: Bool = true

    var myMatchSegmentTitles: [String] = PostedMatchCase.allCases
        .map { $0.rawValue }
        .filter { $0 != PostedMatchCase.allMatches.rawValue }

    var postedMatchCase: PostedMatchCase = .appliedMatch {
        didSet { updateDisplayedMatches() }
    }

    private let userId = UserSessionManager.shared.currentUser?.id
    private var lastAppliedSnapshot: DocumentSnapshot?
    private var lastRecruitingSnapshot: DocumentSnapshot?
    private let pageSize = 5
    private let debounceDelay: UInt64 = 300_000_000
    private let repository: MatchRepository = MatchRepository()
 
    
    
    // MARK: 세그먼트에 따라 경기 필터링
    // - 신청한 경기, 내가 모집중인 경기, 종료된 경기

    /// 필터링 버튼 설정
    @MainActor
    func fetchFilteringButtonTitle(selectedType: String) {
        guard let type = PostedMatchCase(rawValue: selectedType) else { return }
        postedMatchCase = type
        
        filteringButtonTypes = []
        var isMatchEmpty = false
        
        switch type {
        case .appliedMatch:
            filteringButtonTypes = MatchFilter.appliedCases
            selectedFilterButton = .applied(.all)
            isMatchEmpty = appliedMatches.isEmpty
            displayedMatches = appliedMatches
            
        case .myRecruitingMatch:
            filteringButtonTypes = []
            selectedFilterButton = .myRecruting
            isMatchEmpty = recruitingMatches.isEmpty
            displayedMatches = recruitingMatches
            
        case .finishedMatch:
            filteringButtonTypes = MatchFilter.finishedCases
            selectedFilterButton = .finished(.all)
            isMatchEmpty = finishedMatches.isEmpty
            displayedMatches = finishedMatches
            
        default:
            displayedMatches = []
        }
        
        // 데이터가 없을 때만 서버 요청
        if isMatchEmpty {
            lastAppliedSnapshot = nil
            lastRecruitingSnapshot = nil
            hasMore = true
            Task { await loadMoreMatches() }
        }
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
    
    @MainActor
    func filteringButtonTapped(_ filter: MatchFilter) {
        switch filter {
        // 신청한 경기의 경우 - 전체, 확정, 대기, 거절
        case .applied(let subFilter):
            displayedMatches = appliedMatches.filter { match in
                switch subFilter {
                case .all:
                    return true
                case .accepted: return getUserApplyStatus(appliedMatch: match).2 == .accepted
                case .applied:  return getUserApplyStatus(appliedMatch: match).2 == .standby
                case .rejected: return getUserApplyStatus(appliedMatch: match).2 == .rejected
                }
            }
        
        // 내가 모집중인 경기
        case .myRecruting:
            displayedMatches = recruitingMatches
        
        // 종료된 경기
        case .finished(let subFilter):
            guard let userId = UserSessionManager.shared.currentUser?.id else {
                displayedMatches = []
                return
            }
            
            let matches = (appliedMatches + recruitingMatches).filter { $0.status == "finished" }
            
            // 참여자 평가하기 버튼 ui 수정, 본인이 작성한거 프로필 제거
            displayedMatches = matches.filter { match in
                switch subFilter {
                case .all: return true
                case .participated: return match.organizerId != userId
                case .myRecruited: return match.organizerId == userId
                }
            }
        }
    }

    // MARK: 경기 데이터 가져오기
    /// 나의 매치 화면 진입 시 호출
    @MainActor
    func fetchMyMatchData(forceReload: Bool = false) {
        if forceReload {
            
            lastAppliedSnapshot = nil
            lastRecruitingSnapshot = nil
            hasMore = true
            isLoading = false
        }

        Task {
            async let fetchAppliedMatches: Void = loadMoreMatches(for: .appliedMatch)
            async let fetchMyRecruitingMatches: Void = loadMoreMatches(for: .myRecruitingMatch)
            _ = await (fetchAppliedMatches, fetchMyRecruitingMatches)
        }
    }


    @MainActor
    func loadMoreMatches(for type: PostedMatchCase? = nil) async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: debounceDelay)

        let currentType = type ?? postedMatchCase

        do {
            let nextMatches: [Match]
            var fetchedCount: Int = 0

            switch currentType {
            case .appliedMatch: // 신청한 경기
                let page = try await repository.fetchAppliedMatchesPage(
                    with: userId ?? "",
                    pageSize: pageSize,
                    after: lastAppliedSnapshot
                )
                lastAppliedSnapshot = page.lastDocument
                nextMatches = page.matches
                fetchedCount = page.fetchedCount
                appendMatches(&appliedMatches, with: nextMatches)

            case .myRecruitingMatch: // 내가 모집중인 경기
                let page = try await repository.fetchRecruitingMatchesPage(
                    with: userId ?? "",
                    pageSize: pageSize,
                    after: lastRecruitingSnapshot
                )
                lastRecruitingSnapshot = page.lastDocument
                nextMatches = page.matches
                fetchedCount = page.fetchedCount
                appendMatches(&recruitingMatches, with: nextMatches)

            default:
                nextMatches = []
                fetchedCount = 0
            }

            filteringButtonTapped(selectedFilterButton)
            hasMore = fetchedCount == pageSize
        } catch {
            print("추가 데이터 로드 실패: \(error)")
            hasMore = false
        }
    }


    private func appendMatches(_ target: inout [Match], with newMatches: [Match]) {
        let existingIDs = Set(target.map { $0.id })
        let deduped = newMatches.filter { !existingIDs.contains($0.id) }
        target.append(contentsOf: deduped)
    }
    
    // MARK: UI 표시를 위한 함수
    
    private func filteringRejectReason(status: String) -> String {
        return status
            .replacingOccurrences(of: "rejected", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    /// 신청한 경기에 대한 정보 받아오기
    /// - Parameter appliedMatch: 신청한 경기 정보
    /// - Returns: userId, 거절사유, 신청상태
    func getUserApplyStatus(appliedMatch: Match) -> (String, String, ApplyStatus) {
        // 내가 신청한 경기에 대한 정보를 받음
        guard let status = appliedMatch.participants[userId ?? ""] else {
            return (userId ?? "", "", .standby)
        }
        
        let convertedStatus = ApplyStatusConverter.toStatus(from: status)
        // oncvertedStatus가 .standby 거나 .accepted 면 거절사유가 없음 .rejected면 거절사유가 잇음
        let rejectReason = convertedStatus == .rejected ? filteringRejectReason(status: status) : ""
        print("매치아이디:\(appliedMatch.id)")
        print("\(userId), 거절사유 혹은 상태 \(convertedStatus)")
        return (userId ?? "", rejectReason, convertedStatus)
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
