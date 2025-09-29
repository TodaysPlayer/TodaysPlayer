import Foundation

struct Match: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let organizerId: String
    let teamId: String?
    let matchType: String // "individual", "team"
    let location: MatchLocation
    let dateTime: Date
    let duration: Int // 경기 시간 (분)
    let maxParticipants: Int
    let skillLevel: String
    let position: String?
    let price: Int
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
        case teamId
        case matchType
        case location
        case dateTime
        case duration
        case maxParticipants
        case skillLevel
        case position
        case price
        case status
        case tags
        case requirements
        case participants
        case createdAt
        case updatedAt
    }
    
    static let documentIdKey = CodingUserInfoKey(rawValue: "documentId")!
    
    // 기본 초기화자 (SampleDataManager에서 사용)
    init(id: String, title: String, description: String, organizerId: String, teamId: String?, matchType: String, location: MatchLocation, dateTime: Date, duration: Int, maxParticipants: Int, skillLevel: String, position: String?, price: Int, status: String, tags: [String], requirements: String?, participants: [String: String], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.organizerId = organizerId
        self.teamId = teamId
        self.matchType = matchType
        self.location = location
        self.dateTime = dateTime
        self.duration = duration
        self.maxParticipants = maxParticipants
        self.skillLevel = skillLevel
        self.position = position
        self.price = price
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
        self.teamId = try container.decodeIfPresent(String.self, forKey: .teamId)
        self.matchType = try container.decode(String.self, forKey: .matchType)
        self.location = try container.decode(MatchLocation.self, forKey: .location)
        self.dateTime = try container.decode(Date.self, forKey: .dateTime)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.maxParticipants = try container.decode(Int.self, forKey: .maxParticipants)
        self.skillLevel = try container.decode(String.self, forKey: .skillLevel)
        self.position = try container.decodeIfPresent(String.self, forKey: .position)
        self.price = try container.decode(Int.self, forKey: .price)
        self.status = try container.decode(String.self, forKey: .status)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.requirements = try container.decodeIfPresent(String.self, forKey: .requirements)
        self.participants = try container.decode([String: String].self, forKey: .participants)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

struct MatchLocation: Codable {
    let name: String
    let address: String
    let coordinates: Coordinates
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Apply: Codable, Identifiable {
    let id: String
    let matchId: String
    let applicantId: String
    let position: String?
    let participantCount: Int
    let message: String?
    let status: String // "pending", "accepted", "rejected", "cancelled"
    let rejectionReason: String?
    let appliedAt: Date
    let processedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "applyId"
        case matchId
        case applicantId
        case position
        case participantCount
        case message
        case status
        case rejectionReason
        case appliedAt
        case processedAt
    }
}

struct Notification: Codable, Identifiable {
    let id: String
    let type: String // "application_received", "application_accepted", "application_rejected", "match_reminder", "match_cancelled"
    let title: String
    let message: String
    let data: [String: String]? // Any 대신 String으로 변경
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "notificationId"
        case type
        case title
        case message
        case data
        case isRead
        case createdAt
    }
}

struct Review: Codable, Identifiable {
    let id: String
    let matchId: String
    let reviewerId: String
    let revieweeId: String
    let rating: Int // 1-5
    let comment: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "reviewId"
        case matchId
        case reviewerId
        case revieweeId
        case rating
        case comment
        case createdAt
    }
}

struct Favorite: Codable, Identifiable {
    let id: String
    let userId: String
    let matchId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "favoriteId"
        case userId
        case matchId
        case createdAt
    }
}

struct RegionData: Codable, Identifiable {
    let id: String
    let name: String
    let parentRegion: String?
    let coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case id = "regionId"
        case name
        case parentRegion
        case coordinates
    }
}

struct Announcement: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let isImportant: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "announcementId"
        case title
        case content
        case isImportant
        case createdAt
        case updatedAt
    }
}
