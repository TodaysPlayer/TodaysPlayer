//
//  Announcement.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

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

    static let documentIdKey = CodingUserInfoKey(rawValue: "announcementDocumentId")!

    init(id: String, title: String, content: String, isImportant: Bool, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.isImportant = isImportant
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let documentId = decoder.userInfo[Self.documentIdKey] as? String {
            self.id = documentId
        } else if let decodedId = try? container.decode(String.self, forKey: .id) {
            self.id = decodedId
        } else {
            // 마지막 안전장치: 비어있는 문자열로 설정 (실제 운영에서는 문서 ID가 보장되도록 스키마를 맞추는 것을 권장)
            self.id = ""
        }

        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.isImportant = try container.decode(Bool.self, forKey: .isImportant)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
