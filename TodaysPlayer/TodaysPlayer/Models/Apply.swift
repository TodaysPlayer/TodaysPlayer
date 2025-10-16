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
}
