//
//  Apply.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Apply: Codable, Identifiable, Hashable {
    let id: String
    let matchId: String
    let userId: String
    let userNickname: String
    let userSkillLevel: String?
    let position: String?
    let participantCount: Int
    let message: String?
    let status: String // "pending", "accepted", "rejected", "cancelled"
    let rejectionReason: String?
    let appliedAt: Date
    let processedAt: Date?
    let userRate: UserRating

    
    enum CodingKeys: String, CodingKey {
        case id = "applyId"
        case matchId
        case userId
        case userNickname
        case userSkillLevel
        case position
        case participantCount
        case message
        case status
        case rejectionReason
        case appliedAt
        case processedAt
        case userRate
    }
        
    static let documentIdKey = CodingUserInfoKey(rawValue: "documentId")!
        
    // ✅ 1. 일반 초기화 메서드 (직접 객체 생성용)
    init(
        id: String,
        matchId: String,
        userId: String,
        userNickname: String,
        userSkillLevel: String?,
        position: String?,
        participantCount: Int,
        message: String?,
        status: String,
        rejectionReason: String?,
        appliedAt: Date,
        processedAt: Date?,
        userRate: UserRating
    ) {
        self.id = id
        self.matchId = matchId
        self.userId = userId
        self.userNickname = userNickname
        self.userSkillLevel = userSkillLevel
        self.position = position
        self.participantCount = participantCount
        self.message = message
        self.status = status
        self.rejectionReason = rejectionReason
        self.appliedAt = appliedAt
        self.processedAt = processedAt
        self.userRate = userRate
    }
    
    // ✅ 2. 커스텀 디코더 (Firestore 디코딩용)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Firestore 문서 ID를 applyId로 사용
        if let documentId = decoder.userInfo[Self.documentIdKey] as? String {
            self.id = documentId
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.matchId = try container.decode(String.self, forKey: .matchId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userNickname = try container.decode(String.self, forKey: .userNickname)
        self.userSkillLevel = try container.decodeIfPresent(String.self, forKey: .userSkillLevel)
        self.position = try container.decodeIfPresent(String.self, forKey: .position)
        self.participantCount = try container.decode(Int.self, forKey: .participantCount)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.status = try container.decode(String.self, forKey: .status)
        self.rejectionReason = try container.decodeIfPresent(String.self, forKey: .rejectionReason)
        self.appliedAt = try container.decode(Date.self, forKey: .appliedAt)
        self.processedAt = try container.decodeIfPresent(Date.self, forKey: .processedAt)
        self.userRate = try container.decode(UserRating.self, forKey: .userRate)
    }
}

extension Apply {
    var applyStatusEnum: ApplyStatus {
        ApplyStatusConverter.toStatus(from: status)
    }
}
