//
//  Match.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation
import SwiftUI

struct Match: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let organizerId: String
    let organizerName: String
    let organizerProfileURL: String?
    let teamId: String?
    let matchType: String // "individual", "team"
    let gender: String // "male", "female", "mixed"
    let location: MatchLocation
    let dateTime: Date
    let duration: Int // 경기 시간 (분)
    let maxParticipants: Int
    let skillLevel: String
    let position: String?
    let price: Int
    let rating: Double? // 매치 평점 (0.0 ~ 5.0)
    let status: String // "recruiting", "confirmed", "completed", "cancelled"
    let tags: [String]
    let requirements: String?
    let participants: [String: String] // [userId: status] - "accepted", "pending", "rejected"
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "matchId"
        case title
        case description
        case organizerId
        case organizerName
        case organizerProfileURL
        case teamId
        case matchType
        case gender
        case location
        case dateTime
        case duration
        case maxParticipants
        case skillLevel
        case position
        case price
        case rating
        case status
        case tags
        case requirements
        case participants
        case createdAt
        case updatedAt
    }
    
    static let documentIdKey = CodingUserInfoKey(rawValue: "documentId")!
    
    // 기본 초기화자 (SampleDataManager에서 사용)
    init(id: String, title: String, description: String, organizerId: String, organizerName: String, organizerProfileURL: String?, teamId: String?, matchType: String, gender: String, location: MatchLocation, dateTime: Date, duration: Int, maxParticipants: Int, skillLevel: String, position: String?, price: Int, rating: Double?, status: String, tags: [String], requirements: String?, participants: [String: String], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.organizerProfileURL = organizerProfileURL
        self.teamId = teamId
        self.matchType = matchType
        self.gender = gender
        self.location = location
        self.dateTime = dateTime
        self.duration = duration
        self.maxParticipants = maxParticipants
        self.skillLevel = skillLevel
        self.position = position
        self.price = price
        self.rating = rating
        self.status = status
        self.tags = tags
        self.requirements = requirements
        self.participants = participants
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Firebase 문서 ID를 매치 ID로 설정하는 초기화 (Decodable)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 문서 ID를 매치 ID로 사용 (Firebase에서 자동 생성된 ID)
        if let documentId = decoder.userInfo[Self.documentIdKey] as? String {
            self.id = documentId
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.organizerId = try container.decode(String.self, forKey: .organizerId)
        self.organizerName = try container.decode(String.self, forKey: .organizerName)
        self.organizerProfileURL = try container.decode(String.self, forKey: .organizerProfileURL)
        self.teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        self.matchType = try container.decode(String.self, forKey: .matchType)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "mixed" // 기본값: 혼성
        self.location = try container.decode(MatchLocation.self, forKey: .location)
        self.dateTime = try container.decode(Date.self, forKey: .dateTime)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.maxParticipants = try container.decode(Int.self, forKey: .maxParticipants)
        self.skillLevel = try container.decode(String.self, forKey: .skillLevel)
        self.position = try container.decodeIfPresent(String.self, forKey: .position)
        self.price = try container.decode(Int.self, forKey: .price)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.status = try container.decode(String.self, forKey: .status)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.requirements = try container.decodeIfPresent(String.self, forKey: .requirements)
        self.participants = try container.decode([String: String].self, forKey: .participants)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

extension Match {
    /// 매치에 대한 태그 생성
    /// - Returns: 가격, 실력 레벨, 성별, 마감 임박 등에 따른 태그 배열
    func createMatchTags() -> [MatchTag] {
        var tags: [MatchTag] = []
        
        // 가격 태그
        if self.price == 0 {
            tags.append(MatchTag(text: "무료", color: .green, icon: "gift.fill"))
        } else if self.price <= 5000 {
            tags.append(MatchTag(text: "저렴", color: .blue, icon: "wonsign.circle.fill"))
        }
        
        // 실력 레벨 태그
        if self.skillLevel == "beginner" {
            tags.append(MatchTag(text: "초보환영", color: .blue, icon: "person.fill"))
        }
        
        // 성별 태그
        switch self.gender {
        case "male":
            tags.append(MatchTag(text: "남성", color: .blue, icon: "person"))
        case "female":
            tags.append(MatchTag(text: "여성", color: .pink, icon: "person"))
        case "mixed":
            tags.append(MatchTag(text: "혼성", color: .purple, icon: "person.2"))
        default:
            break
        }
        
        // 마감 임박 태그 (참가자 수 기반)
        let participantRatio = Double(self.participants.count) / Double(self.maxParticipants)
        if participantRatio >= 0.8 {
            tags.append(MatchTag(text: "마감임박", color: .orange, icon: "bolt.fill"))
        }
        
        return tags
    }
    
    /// 성별을 한국어로 변환
    var genderKorean: String {
        switch self.gender {
        case "male": return "남성"
        case "female": return "여성"
        case "mixed": return "혼성"
        default: return "혼성"
        }
    }
    
    func convertMatchType(type: String) -> MatchType {
        switch type {
        case "futsal": return .futsal
        case "soccer": return .soccer
        default: return .futsal
        }
    }

}

extension Match {
    /// 현재 수락된 참가자 수
    var appliedParticipantsCount: Int {
        participants.values.filter { $0 == "accepted" }.count
    }
    
    /// 모집 인원이 가득 찼는지 확인
    var isFull: Bool {
        appliedParticipantsCount >= maxParticipants
    }
    
    /// 모집 중인지 확인 (신청 가능 여부)
    var isRecruiting: Bool {
        status == "recruiting" && !isFull
    }
    
    /// 버튼에 표시할 텍스트
    var buttonTitle: String {
        if isFull || status == "closed" {
            return "모집마감"
        } else if status == "confirmed" {
            return "경기확정"
        } else if status == "completed" {
            return "경기종료"
        } else if status == "cancelled" {
            return "경기취소"
        } else {
            return "신청하기"
        }
    }
}
