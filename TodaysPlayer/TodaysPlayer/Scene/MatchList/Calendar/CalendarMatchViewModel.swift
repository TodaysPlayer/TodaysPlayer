//
//  CalendarMatchViewModel.swift
//  TodaysPlayer
//
//  Created on 12/09/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

@Observable
final class CalendarMatchViewModel {
    // 날짜별로 그룹화된 경기 데이터
    var matchesByDate: [Date: [Match]] = [:]
    
    // 사용자의 신청 정보 (matchId: Apply)
    var userApplies: [String: Apply] = [:]
    
    var isLoading: Bool = false
    var toastManager: ToastMessageManager = ToastMessageManager()
    
    // 경기 종료 관련
    var finishedMatchId: String = "" {
        didSet { isFinishMatchAlertShow.toggle() }
    }
    
    var finishedMatchWithRatingId: String = "" {
        didSet {
            toastManager.show(.finishRate)
            Task { await finishSelectedMatchWithRating() }
        }
    }
    
    var isFinishMatchAlertShow: Bool = false
    
    private let userId = UserSessionManager.shared.currentUser?.id
    private let repository = MatchRepository()
    
    // MARK: - Fetch Matches for Month
    
    /// 특정 월의 모든 경기를 가져오기
    @MainActor
    func fetchMatchesForMonth(date: Date) {
        guard let userId = userId else {
            print("❌ CalendarMatchViewModel: userId is nil")
            return
        }
        
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                // 해당 월의 시작일과 종료일 계산
                let calendar = Calendar.current
                guard let interval = calendar.dateInterval(of: .month, for: date) else { 
                    print("❌ CalendarMatchViewModel: Failed to get month interval")
                    return 
                }
                
                print("📅 Fetching matches for: \(interval.start) ~ \(interval.end)")
                
                // 기존 Repository 메서드를 활용하여 모든 경기 가져오기
                let (appliedMatches, recruitingMatches, finishedMatches) = try await repository.fetchMatchesForCalendar(
                    userId: userId,
                    startDate: interval.start,
                    endDate: interval.end
                )
              
                // Apply 정보도 함께 가져오기
                await fetchApplyInformation(for: appliedMatches, userId: userId)
                
                // 모든 경기를 날짜별로 그룹화
                await groupMatchesByDate(
                    appliedMatches: appliedMatches,
                    recruitingMatches: recruitingMatches,
                    finishedMatches: finishedMatches
                )
//                
//                for (date, matches) in matchesByDate.sorted(by: { $0.key < $1.key }) {
//                    print("  📆 \(date): \(matches.count) matches")
//                }
                
            } catch {
                print("❌ Error fetching matches: \(error)")
            }
        }
    }
    
    // MARK: - Apply Information
    
    /// Apply 정보 가져오기
    @MainActor
    private func fetchApplyInformation(for matches: [Match], userId: String) async {
        // 모든 Apply 정보를 한번에 가져오기
        do {
            let applyQuery = Firestore.firestore()
                .collection("apply")
                .whereField("userId", isEqualTo: userId)
            
            let snapshot = try await applyQuery.getDocuments()
            let applies = snapshot.documents.compactMap { doc -> Apply? in
                var apply = try? doc.data(as: Apply.self)
                // documentId를 applyId로 설정
                if apply != nil {
                    let decoder = Firestore.Decoder()
                    decoder.userInfo[Apply.documentIdKey] = doc.documentID
                    apply = try? doc.data(as: Apply.self, decoder: decoder)
                }
                return apply
            }
            
            // matchId를 키로 하여 Apply 정보 저장
            for apply in applies {
                userApplies[apply.matchId] = apply
            }
          } catch {
            print("❌ Error fetching apply information: \(error)")
        }
    }
    
    // MARK: - Group Matches by Date
    
    @MainActor
    private func groupMatchesByDate(
        appliedMatches: [Match],
        recruitingMatches: [Match],
        finishedMatches: [Match]
    ) async {
        let calendar = Calendar.current
        var grouped: [Date: [Match]] = [:]
        
        let allMatches = appliedMatches + recruitingMatches + finishedMatches
        
        // 중복 제거 (같은 matchId는 하나만)
        var uniqueMatches: [String: Match] = [:]
        for match in allMatches {
            uniqueMatches[match.id] = match
        }
        
        // 날짜별로 그룹화
        for match in uniqueMatches.values {
            let startOfDay = calendar.startOfDay(for: match.dateTime)
            grouped[startOfDay, default: []].append(match)
        }
        
        // 각 날짜의 경기를 시간순으로 정렬
        for (date, matches) in grouped {
            grouped[date] = matches.sorted { $0.dateTime < $1.dateTime }
        }
        
        matchesByDate = grouped
    }
    
    // MARK: - Helper Methods
    
    /// 특정 날짜에 경기가 있는지 확인
    func hasMatches(on date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return matchesByDate[startOfDay] != nil && !matchesByDate[startOfDay]!.isEmpty
    }
    
    /// 특정 날짜의 경기 개수
    func getMatchCount(on date: Date) -> Int {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return matchesByDate[startOfDay]?.count ?? 0
    }
    
    /// 내가 모집중인 경기인지 확인
    func isMyRecruitingMatch(_ match: Match) -> Bool {
        guard let userId = userId else { return false }
        return match.organizerId == userId && match.status != "finished"
    }
    
    /// 경기의 상태 태그 생성
    func getMatchTags(for match: Match) -> [MatchTag] {
        guard let userId = userId else { return [] }
        
        var tags: [MatchTag] = []
        
        // 1. 경기 주최자인지 확인 (가장 먼저 표시)
        if match.organizerId == userId {
            if match.status == "finished" {
                tags.append(MatchTag(text: "모집완료", color: .gray, icon: "checkmark.circle.fill"))
            } else {
                tags.append(MatchTag(text: "모집중", color: .blue, icon: "megaphone.fill"))
            }
        }
        
        // 2. 신청한 경기인지 확인 (Apply 정보 사용)
        if let apply = userApplies[match.id] {
            #if DEBUG
            print("  🏷️ Tag for match \(match.id): apply.status = \(apply.status)")
            #endif
            
            switch apply.status {
            case "accepted":
                tags.append(MatchTag(text: "확정", color: .green, icon: "checkmark.circle.fill"))
            case "pending":
                tags.append(MatchTag(text: "대기중", color: .orange, icon: "clock.fill"))
            case "rejected":
                tags.append(MatchTag(text: "거절", color: .red, icon: "xmark.circle.fill"))
            case "cancelled":
                tags.append(MatchTag(text: "취소됨", color: .gray, icon: "xmark.circle"))
            default:
                #if DEBUG
                print("  ⚠️ Unknown apply status: \(apply.status)")
                #endif
                break
            }
        } else {
            #if DEBUG
            print("  ⚠️ No apply found for match \(match.id)")
            #endif
        }
        
        // 3. 종료된 경기
        if match.status == "finished" {
            tags.append(MatchTag(text: "종료", color: .gray, icon: "flag.checkered"))
            
            // 참여했던 경기인지 확인
            if let participantStatus = match.participants[userId], participantStatus == "accepted" {
                tags.append(MatchTag(text: "참여완료", color: .purple, icon: "person.fill.checkmark"))
            }
        }
        
        // 4. 경기 타입
        switch match.matchType {
        case "futsal":
            tags.append(MatchTag(text: "풋살", color: .cyan, icon: "sportscourt.fill"))
        case "soccer":
            tags.append(MatchTag(text: "축구", color: .green, icon: "figure.soccer"))
        default:
            break
        }
        
        return tags
    }
    
    // MARK: - Match Actions
    
    /// 경기 종료 처리
    func finishSelectedMatch() async {
        guard !finishedMatchId.isEmpty else { return }
        
        await repository.eidtMatchStatusToFinish(matchId: finishedMatchId)
        
        // 로컬 데이터 업데이트
        updateLocalMatchStatus(matchId: finishedMatchId, newStatus: "finished")
        
        finishedMatchId = ""
        toastManager.show(.finishMatch)
    }
    
    /// 평가 완료 후 경기 종료
    func finishSelectedMatchWithRating() async {
        guard !finishedMatchWithRatingId.isEmpty else { return }
        
        await repository.eidtMatchStatusToFinish(matchId: finishedMatchWithRatingId, withRate: true)
        
        // 로컬 데이터 업데이트
        updateLocalMatchStatus(matchId: finishedMatchWithRatingId, newStatus: "finished")
        
        finishedMatchWithRatingId = ""
    }
    
    @MainActor
    private func updateLocalMatchStatus(matchId: String, newStatus: String) {
        for (date, matches) in matchesByDate {
            if let index = matches.firstIndex(where: { $0.id == matchId }) {
                var updatedMatch = matches[index]
   
                // 현재 표시된 날짜의 데이터 다시 로드
                if let firstMatch = matchesByDate[date]?.first {
                    fetchMatchesForMonth(date: firstMatch.dateTime)
                }
                break
            }
        }
    }
}
