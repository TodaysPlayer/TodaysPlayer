//
//  PlayerRatingViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/10/25.
//

import Foundation


@Observable
final class PlayerRatingViewModel {
    var matchInfo: Match
    var expandedUserID: String? = nil   // 평가하기 버튼 터치 시 확장여부
    var ratings: [String: [UserRatingCategory: Int]] = [:] // [userId : [평가항목 : 점수]]
    var completedRatings: Set<String> = [] // 평가 완료된 유저 ID

    var participatedUsers: [User] = []
    private var userIds: [String] = []

    private let repository: UserDataRepository = UserDataRepository()
  
    init(matchInfo: Match) {
        self.matchInfo = matchInfo
        self.userIds = matchInfo.participants.map { $0.key }
        Task {
            do {
                self.participatedUsers = try await fetchUserData()
            } catch {
                print("Error fetching user data: \(error)")
            }
        }
    }
    
    
    /// 평가버튼 터치 시 평가항목 확장
    func toggleExpanded(_ userID: String) {
        // 이미 열려있는 상태에서 닫을 때
        if expandedUserID == userID {
            // 평가한 항목이 없는 경우 모든 항목을 4점으로 설정
            if !hasUserRated(userID) {
                setDefaultRatings(for: userID)
            }
            // 닫을 때 completedRatings에 추가하여 "수정하기"로 표시
            completedRatings.insert(userID)
        }
        
        expandedUserID = (expandedUserID == userID) ? nil : userID
    }
    
    /// 사용자에게 기본 평가값(4점) 설정
    private func setDefaultRatings(for userID: String) {
        var userRating: [UserRatingCategory: Int] = ratings[userID] ?? [:]
        
        // 입력이 되지 않은 평가 항목에 대해 4점으로 설정
        for category in UserRatingCategory.allCases {
            if userRating[category] == nil || userRating[category] == 0 {
                userRating[category] = 4
            }
        }
        
        ratings[userID] = userRating
    }
    
    /// 모든 참여자에게 기본 평가값 설정 (평가하지 않은 경우)
    private func setDefaultRatingsForAllUsers() {
        for user in participatedUsers {
            setDefaultRatings(for: user.id)
        }
    }
    
    /// 평가여부 체크
    func checkCompledtedRating(_ userID: String) -> Bool {
        completedRatings.contains(userID)
    }
    
    /// 사용자가 평가한 항목이 있는지 확인
    func hasUserRated(_ userID: String) -> Bool {
        guard let userRatings = ratings[userID] else { return false }
        return userRatings.values.contains { $0 > 0 }
    }
    
    /// 경기 참여자 정보 가져오기
    func fetchUserData() async throws -> [User] {
        // 매치아이디를 가지고 참여항목에 속한 유저 id 필터링
        var userDatas: [User] = []
        
        // 유저 id를 토대로 개별 데이터 가져오기
        try await withThrowingTaskGroup(of: User?.self) { group in
            for userID in userIds {
                group.addTask {
                    guard let data = await self.repository.fetchUserData(with: userID) else { return nil }
                    return data
                }
            }
            
            for try await data in group {
                guard let _data = data else { continue }
                userDatas.append(_data)
            }
        }
        
        return userDatas
    }

    /// 평가한 항목 저장하기
    @MainActor
    func updateUserRate() async{
        // 저장하기를 누르거나 뒤로가기 누르면 각 데이터에 저장하기
        print("기존 ratings: \(ratings)")
        
        // 모든 참여자에게 기본 평가값 설정 (평가하지 않은 경우)
        setDefaultRatingsForAllUsers()
        
        print("✅ 보정된 ratings: \(ratings)")
        
        // 보정된 값을 가지고 기존 User데이터에 해당 평점을 넣어주고 하나씩 업데이트
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for userId in userIds {
                    guard let userData = participatedUsers.first(where: { $0.id == userId }) else { 
                        print("❌ 사용자 데이터를 찾을 수 없음: \(userId)")
                        continue 
                    }
                    
                    let rating = ratings[userId] ?? [:]
                
                    group.addTask {
                        // 서버에서 수정이 안됨
                        await self.repository.editUserRateData(user: userData, rating: rating)
                    }
                }
                
                // 모든 태스크가 완료될 때까지 대기
                for try await _ in group {
                    // 각 태스크가 완료됨
                }
            }
            print("✅ 모든 사용자 평점 업데이트 완료")
        } catch {
            print("❌ 사용자 평점 업데이트 실패: \(error)")
        }


    }

}
