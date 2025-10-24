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
    
    // 세그먼트버튼의 타이틀
    var filteringButtonTypes: [MatchFilter] = MatchFilter.appliedCases
    // 선택된 세그먼트 버튼
    var selectedFilterButton: MatchFilter = .applied(.all) {
        didSet { updateDisplayedMatches(selectedFilterButton) }
    }
    
    var isLoading: Bool = false
    var hasMore: Bool = true

    var myMatchSegmentTitles: [String] = PostedMatchCase.allCases
        .map { $0.rawValue }
        .filter { $0 != PostedMatchCase.allMatches.rawValue }

    // 게시글 타입
    var postedMatchCase: PostedMatchCase = .appliedMatch

    private let userId = UserSessionManager.shared.currentUser?.id
    private var lastAppliedSnapshot: DocumentSnapshot?
    private var lastRecruitingSnapshot: DocumentSnapshot?
    private let pageSize = 5
    private let debounceDelay: UInt64 = 300_000_000
    private let repository: MatchRepository = MatchRepository()
    var toastManager: ToastMessageManager = ToastMessageManager()
    
    // 경기를 종료하기위한 id
    var finishedMatchId: String = "" {
        didSet { isFinishMatchAlertShow.toggle() }
    }
    
    // 평가가 완료된 경기 id
    var finishedMatchWithRatingId: String = "" {
        didSet {
            toastManager.show(.finishRate)
            Task { await finishSelectedMatchWithRating() }
        }
    }
    
    var isFinishMatchAlertShow: Bool = false
    private var updateTask: Task<Void, Never>?
    
    // 정렬 상태
    var sortOption: MatchSortOption = .matchDateDesc {
        didSet { sortDisplayedMatches() }
    }
    
    // MARK: 세그먼트에 따라 경기 필터링
    // - 신청한 경기, 내가 모집중인 경기, 종료된 경기

    /// 필터링 버튼 설정
    @MainActor
    func fetchFilteringButtonTitle(selectedType: String) {
        updateTask?.cancel()
        
        updateTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: debounceDelay)
            
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
    }

    
    
    /// 경기 종류에 따라 보여지는 경기 변경
    /// - 신청한 경기, 내가 모집중인 경기, 종료된 경기
    private func updateDisplayedMatches(_ filter: MatchFilter)  {
        updateTask?.cancel()
        
        updateTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: debounceDelay)
         
             filteringButtonTapped(filter)
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
            displayedMatches = recruitingMatches.filter({ $0.status != "finished" })
        
        // 종료된 경기
        case .finished(let subFilter):
            guard let userId = UserSessionManager.shared.currentUser?.id else {
                displayedMatches = []
                return
            }
            
            let matches = finishedMatches
            
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
    func fetchMyMatchData() {
        lastAppliedSnapshot = nil
        lastRecruitingSnapshot = nil
        hasMore = true
        isLoading = false
                
        Task {
            async let fetchAppliedMatches: Void = loadMoreMatches(
                for: .appliedMatch,
                shouldUpdateDisplay: true,
                isInitial: true
            )
            async let fetchMyRecruitingMatches: Void = loadMoreMatches(
                for: .myRecruitingMatch,
                shouldUpdateDisplay: false,
                isInitial: true
            )
            async let fetchFinishedMatches: Void = loadMoreMatches(
                for: .finishedMatch,
                shouldUpdateDisplay: false,
                isInitial: true
            )
            _ = await (fetchAppliedMatches, fetchMyRecruitingMatches, fetchFinishedMatches)
        }
    }


    @MainActor
    func loadMoreMatches(
        for type: PostedMatchCase? = nil,
        shouldUpdateDisplay: Bool = true,
        isInitial: Bool = false
    ) async {
        if !isInitial {
            guard !isLoading, hasMore else { return }
        }
        
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: debounceDelay)

        let currentType = type ?? postedMatchCase

        do {
            var nextMatches: [Match] = []
            var fetchedCount: Int = 0

            switch currentType {
            case .appliedMatch:
                let page = try await repository.fetchAppliedMatchesPage(
                    with: userId ?? "",
                    pageSize: pageSize,
                    after: lastAppliedSnapshot
                )
                lastAppliedSnapshot = page.lastDocument
                nextMatches = page.matches
                fetchedCount = page.fetchedCount
                appendMatches(&appliedMatches, with: nextMatches)

            case .myRecruitingMatch:
                let page = try await repository.fetchRecruitingMatchesPage(
                    with: userId ?? "",
                    pageSize: pageSize,
                    after: lastRecruitingSnapshot
                )
                lastRecruitingSnapshot = page.lastDocument
                nextMatches = page.matches.filter({ $0.status != "finished" })
                fetchedCount = page.fetchedCount
                appendMatches(&recruitingMatches, with: nextMatches)

            case .finishedMatch:
                let matches = try await repository.fetchFinishedMatches(with: userId ?? "")
                fetchedCount = matches.count
                appendMatches(&finishedMatches, with: matches)
            default:
                break
            }

            // 갱신이 필요할 때만 수행
            if shouldUpdateDisplay {
                updateDisplayedMatches(selectedFilterButton)
            }

            hasMore = fetchedCount == pageSize && currentType != .finishedMatch

        } catch {
            print("❌ 추가 데이터 로드 실패:", error)
            hasMore = false
        }
    }

    private func appendMatches(_ target: inout [Match], with newMatches: [Match]) {
        var matchDict = Dictionary(uniqueKeysWithValues: target.map { ($0.id, $0) })
    
        for newMatch in newMatches {
            matchDict[newMatch.id] = newMatch
        }
    
        // 최신 날짜순으로 변경
        target = matchDict.values.sorted(by: {
            $0.updatedAt > $1.updatedAt
        })
    }

    
    // MARK: 경기 종료하기
    @MainActor
    func finishSelectedMatch() async {
        guard !finishedMatchId.isEmpty,
              let finishedMatch = recruitingMatches.filter({ $0.id == finishedMatchId }).first
        else { return }
                
        recruitingMatches.removeAll { $0 == finishedMatch }
        finishedMatches.append(finishedMatch)
        
        // 보여줄 데이터 다시 넣어주기
        updateDisplayedMatches(.myRecruting)
        
        // 서버에서 처리해주기
        await repository.eidtMatchStatusToFinish(matchId: finishedMatchId)
        
        finishedMatchId = ""
        isFinishMatchAlertShow = false
        
        toastManager.show(.finishMactch)
    }
    
    // MARK: 평가가 완료된 경기처리
    @MainActor
    private func finishSelectedMatchWithRating() async{
        guard !finishedMatchWithRatingId.isEmpty,
              let finishedRatingMatch = finishedMatches.filter({ $0.id == finishedMatchWithRatingId }).first
        else { return }
        
        // 새로운 데이터 만들기
        var ratedMatch = finishedRatingMatch
        ratedMatch.rating = 1.0

        // 경기 데이터 재설정 후 다시 넣기
        finishedMatches.removeAll { $0 == finishedRatingMatch }
        finishedMatches.append(ratedMatch)
        
        // 서버 반영
        await repository.eidtMatchStatusToFinish(matchId: finishedRatingMatch.id, withRate: true)
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
        let rejectReason = convertedStatus == .rejected ? filteringRejectReason(status: status) : ""
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
    
    /// displayedMatches를 현재 정렬 설정에 따라 정렬
    @MainActor
    func sortDisplayedMatches() {
        displayedMatches.sort { a, b in
            switch sortOption {
            case .matchDateAsc:
                return a.dateTime < b.dateTime
            case .matchDateDesc:
                return a.dateTime > b.dateTime
            case .createdAtAsc:
                return a.createdAt < b.createdAt
            case .createdAtDesc:
                return a.createdAt > b.createdAt
            }
        }
    }
    
}
