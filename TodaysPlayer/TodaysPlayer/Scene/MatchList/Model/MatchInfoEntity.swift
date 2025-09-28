//
//  MatchInfoEntity.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/26/25.
//

import Foundation

enum MatchType: String {
    case soccer = "축구"
    case futsal = "풋살"
}

enum ApplyStatus: String {
    case standby = "대기중"
    case confirmed = "확정"
    case rejected = "거절"
}


/// 매치 정보 Entity
/// - 서버에서 오는 데이터
struct MatchInfoEntity: Decodable {
    let matchId: String?
    let matchType: String?
    let applyStatus: String?
    let matchLocation: String?
    let matchTitle: String?
    let matchTime: String?
    let applyCount: Int?
    let maxCount: Int?
    let matchFee: Int?
    let genderLimit: String?
    let levelLimit: String?
    let imageURL: String?
    let postUserName: String?
}


/// 매칭 정보 Domain Model
/// - 앱에서 사용
struct MatchInfo {
    let matchId: String
    let matchType: MatchType
    let applyStatus: ApplyStatus
    let matchLocation: String
    let matchTitle: String
    let matchTime: String
    let applyCount: Int
    let maxCount: Int
    let matchFee: Int
    let genderLimit: String
    let levelLimit: String
    let imageURL: String
    let postUserName: String
}

extension MatchInfo {
    init(entity: MatchInfoEntity) {
        self.matchId = entity.matchId ?? ""
        self.matchType = MatchType(rawValue: entity.matchType ?? "") ?? .futsal
        self.applyStatus = ApplyStatus(rawValue: entity.applyStatus ?? "") ?? .standby
        self.matchLocation = entity.matchLocation ?? ""
        self.matchTitle = entity.matchTitle ?? ""
        self.matchTime = entity.matchTime ?? ""
        self.applyCount = entity.applyCount ?? 0
        self.maxCount = entity.maxCount ?? 0
        self.matchFee = entity.matchFee ?? 0
        self.genderLimit = entity.genderLimit ?? "무관"
        self.levelLimit = entity.levelLimit ?? "무관"
        self.imageURL = entity.imageURL ?? ""
        self.postUserName = entity.postUserName ?? ""
    }
}
