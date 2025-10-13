//
//  PlayerRatingViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/10/25.
//

import Foundation

@Observable
final class PlayerRatingViewModel {
    var matchInfo: MatchInfo
    var expandedUserID: String? = nil   // 평가하기 버튼 터치 시 확장여부
    var ratings: [String: [String: Int]] = [:] // userID별로 항목별 점수 저장
    var comments: [String: String] = [:]
    var completedRatings: Set<String> = [] // 평가 완료된 유저 ID
    let ratingList: [(String, String)] = [
        ("heart", "매너"),
        ("person.2", "팀워크"),
        ("timer", "시간약속")
    ]
    
    let participatedUsers: [User] = [
        User(
            id: "bJYjlQZuaqvw2FDB5uNa",
            email: "player1@example.com",
            displayName: "축구왕김철수",
            profileImageUrl: nil,
            phoneNumber: "010-1234-5678",
            position: "공격수",
            skillLevel: "중급",
            preferredRegions: ["서울특별시", "경기도"],
            isTeamLeader: true,
            teamId: nil,
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        User(
            id: "player2",
            email: "player2@example.com",
            displayName: "미드필더박영희",
            profileImageUrl: nil,
            phoneNumber: "010-2345-6789",
            position: "미드필더",
            skillLevel: "상급",
            preferredRegions: ["경기도", "인천광역시"],
            isTeamLeader: false,
            teamId: nil,
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        )
    ]
    
    init(matchInfo: MatchInfo) {
        self.matchInfo = matchInfo
    }
    
    
    /// 평가버튼 터치 시 평가항목 확장
    func toggleExpanded(_ userID: String) {
        expandedUserID = (expandedUserID == userID) ? nil : userID
    }
    
    /// 평가여뷰 체크
    func checkCompledtedRating(_ userID: String) -> Bool {
        completedRatings.contains(userID)
    }

}
