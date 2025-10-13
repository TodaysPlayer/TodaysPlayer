//
//  Favorite.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Favorite: Codable, Identifiable {
    let id: String           // Firebase 문서 ID
    let userId: String
    let matchId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "favoriteId" 
        case userId
        case matchId
        case createdAt
    }
    
    // Match.swift와 동일한 패턴
    static let documentIdKey = CodingUserInfoKey(rawValue: "documentId")!
    
    // 일반 초기화자
    init(id: String, userId: String, matchId: String, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.matchId = matchId
        self.createdAt = createdAt
    }
    
    // Firebase 디코딩용 초기화자 (Match.swift와 동일한 패턴)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 문서 ID를 favorite ID로 사용 (Firebase에서 자동 생성된 ID)
        if let documentId = decoder.userInfo[Self.documentIdKey] as? String {
            self.id = documentId
        } else {
            // 폴백: favoriteId 필드가 있다면 사용
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.userId = try container.decode(String.self, forKey: .userId)
        self.matchId = try container.decode(String.self, forKey: .matchId)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}
