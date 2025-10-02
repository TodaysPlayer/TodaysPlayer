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
}
