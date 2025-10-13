//
//  User.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    let email: String
    let displayName: String
    let profileImageUrl: String?
    let phoneNumber: String?
    let position: String?
    let skillLevel: String?
    let preferredRegions: [String]
    let isTeamLeader: Bool
    let teamId: String?
    let createdAt: Date
    let updatedAt: Date
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case email
        case displayName
        case profileImageUrl
        case phoneNumber
        case position
        case skillLevel
        case preferredRegions
        case isTeamLeader
        case teamId
        case createdAt
        case updatedAt
        case isActive
    }
    
    enum DocumentIdKey: CodingKey {
        case documentId
    }
    
    static let documentIdKey = CodingUserInfoKey(rawValue: "documentId")!
    
    // 기본 초기화자 (SampleDataManager에서 사용)
    init(id: String, email: String, displayName: String, profileImageUrl: String?, phoneNumber: String?, position: String?, skillLevel: String?, preferredRegions: [String], isTeamLeader: Bool, teamId: String?, createdAt: Date, updatedAt: Date, isActive: Bool) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
        self.position = position
        self.skillLevel = skillLevel
        self.preferredRegions = preferredRegions
        self.isTeamLeader = isTeamLeader
        self.teamId = teamId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
    }
    
    // Firebase 문서 ID를 사용자 ID로 설정하는 초기화 (Decodable)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 문서 ID를 사용자 ID로 사용 (Firebase에서 자동 생성된 ID)
        if let documentId = decoder.userInfo[Self.documentIdKey] as? String {
            self.id = documentId
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.email = try container.decode(String.self, forKey: .email)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.position = try container.decodeIfPresent(String.self, forKey: .position)
        self.skillLevel = try container.decodeIfPresent(String.self, forKey: .skillLevel)
        self.preferredRegions = try container.decode([String].self, forKey: .preferredRegions)
        self.isTeamLeader = try container.decode(Bool.self, forKey: .isTeamLeader)
        self.teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
    }
}
