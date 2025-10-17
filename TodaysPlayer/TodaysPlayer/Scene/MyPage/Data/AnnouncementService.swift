//
//  AnnouncementService.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import FirebaseFirestore

struct AnnouncementService {
    struct ServiceError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    private let db = Firestore.firestore()

    func fetch() async throws -> [Announcement] {
        // announcements 컬렉션에서 문서 읽기
        let snapshot = try await db.collection("announcements").getDocuments()
        // 문서 -> Announcement 매핑
        let items: [Announcement] = snapshot.documents.compactMap { (doc) -> Announcement? in
            let data = doc.data()
            // 예상 필드: title(String), content(String)
            guard let title = data["title"] as? String else { return nil }
            let content = (data["content"] as? String) ?? ""

            // Additional fields
            let isImportant = (data["isImportant"] as? Bool) ?? false

            // Firestore Timestamp -> Date conversion for createdAt, updatedAt
            let createdAtDate: Date = {
                if let ts = data["createdAt"] as? Timestamp { return ts.dateValue() }
                if let seconds = data["createdAt"] as? TimeInterval { return Date(timeIntervalSince1970: seconds) }
                return Date()
            }()

            let updatedAtDate: Date = {
                if let ts = data["updatedAt"] as? Timestamp { return ts.dateValue() }
                if let seconds = data["updatedAt"] as? TimeInterval { return Date(timeIntervalSince1970: seconds) }
                return createdAtDate
            }()

            // Announcement가 id를 String/UUID 어느 쪽이든 받을 수 있도록 가정
            // id가 모델에 필요하므로 문서 ID를 사용
            // 아래는 일반적인 이니셜라이저 예시입니다. 프로젝트의 실제 이니셜라이저에 맞게 조정하세요.
            // 예: Announcement(id: String, title: String, content: String)
            return Announcement(id: doc.documentID, title: title, content: content, isImportant: isImportant, createdAt: createdAtDate, updatedAt: updatedAtDate)
        }
        return items
    }
}
