//
//  MyPageRepository.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/17/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

private struct FirestoreProfile {
    let name: String
    let nickname: String
    let position: String
    let level: String
    let avatarURL: String
    let region: String
    let preferredTimes: [String]
    let intro: String

    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.nickname = data["nickname"] as? String ?? ""
        self.position = data["position"] as? String ?? ""
        self.level = data["level"] as? String ?? ""
        self.avatarURL = data["avatarURL"] as? String ?? ""
        self.region = data["region"] as? String ?? ""
        self.preferredTimes = data["preferredTimes"] as? [String] ?? []
        self.intro = data["intro"] as? String ?? ""
    }
}

enum MyPageRepositoryError: Error {
    case documentNotFound
    case decodingError
}

final class MyPageRepository {
    private let firestore = Firestore.firestore()
    
    func fetchUserProfile(uid: String) async throws -> UserProfile {
        try await withCheckedThrowingContinuation { continuation in
            firestore.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    continuation.resume(throwing: MyPageRepositoryError.documentNotFound)
                    return
                }
                let data = snapshot.data() ?? [:]
                let firestoreProfile = FirestoreProfile(data: data)

                let profile = UserProfile(
                    name: firestoreProfile.name,
                    nickname: firestoreProfile.nickname,
                    position: firestoreProfile.position,
                    level: firestoreProfile.level,
                    avatarURL: firestoreProfile.avatarURL
                )

                continuation.resume(returning: profile)
            }
        }
    }
    
    func updateUserProfile(uid: String, profile: UserProfile) async throws {
        let data: [String: Any] = [
            "name": profile.name,
            "nickname": (profile.nickname ?? ""),
            "position": (profile.position ?? ""),
            "level": (profile.level ?? ""),
            "avatarURL": (profile.avatarURL ?? "")
        ]
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            firestore.collection("users").document(uid).setData(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

