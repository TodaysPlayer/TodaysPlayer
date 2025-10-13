//
//  ParticipantEntity.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import Foundation

struct ParticipantEntity: Hashable {
    let matchId: Int
    let userName: String
    let userNickName: String
    let userProfile: String
    let userLevel: String
    let userPosition: String
    let description: String
    let appliedDate: String
    var status: ApplyStatus
    var rejectionReason: String?
}

var mockParticipants: [ParticipantEntity] = [
    ParticipantEntity(
        matchId: 1,
        userName: "Kim Minsoo",
        userNickName: "Min",
        userProfile: "profile1.png",
        userLevel: "Gold",
        userPosition: "FW",
        description: "열정적인 공격수",
        appliedDate: "2025-09-26",
        status: .standby
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Lee Jieun",
        userNickName: "Jie",
        userProfile: "profile2.png",
        userLevel: "Silver",
        userPosition: "MF",
        description: "패스가 좋아요",
        appliedDate: "2025-09-25",
        status: .accepted
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Park Hyun",
        userNickName: "Hyun",
        userProfile: "profile3.png",
        userLevel: "Bronze",
        userPosition: "DF",
        description: "수비 강함",
        appliedDate: "2025-09-24",
        status: .rejected
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Choi Bora",
        userNickName: "Bora",
        userProfile: "profile4.png",
        userLevel: "Gold",
        userPosition: "GK",
        description: "골키퍼 경험 많음",
        appliedDate: "2025-09-23",
        status: .standby
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Jung Ho",
        userNickName: "Ho",
        userProfile: "profile5.png",
        userLevel: "Silver",
        userPosition: "FW",
        description: "슛 정확함",
        appliedDate: "2025-09-22",
        status: .accepted
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Kang Soyeon",
        userNickName: "Soyeon",
        userProfile: "profile6.png",
        userLevel: "Gold",
        userPosition: "MF",
        description: "패스와 슈팅 모두 가능",
        appliedDate: "2025-09-21",
        status: .standby
        
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Yoo Jin",
        userNickName: "Jin",
        userProfile: "profile7.png",
        userLevel: "Bronze",
        userPosition: "DF",
        description: "수비 안정적",
        appliedDate: "2025-09-20",
        status: .rejected
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Han Doyun",
        userNickName: "Doyun",
        userProfile: "profile8.png",
        userLevel: "Silver",
        userPosition: "GK",
        description: "골킥 능숙",
        appliedDate: "2025-09-19",
        status: .accepted
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Lim Seojin",
        userNickName: "Seojin",
        userProfile: "profile9.png",
        userLevel: "Gold",
        userPosition: "FW",
        description: "빠른 발",
        appliedDate: "2025-09-18",
        status: .standby
    ),
    ParticipantEntity(
        matchId: 1,
        userName: "Seo Minji",
        userNickName: "Minji",
        userProfile: "profile10.png",
        userLevel: "Silver",
        userPosition: "MF",
        description: "중거리 슛 가능",
        appliedDate: "2025-09-17",
        status: .accepted
    )
]
