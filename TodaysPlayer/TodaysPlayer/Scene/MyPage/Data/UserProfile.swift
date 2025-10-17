//
//  UserProfile.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/17/25.
//


import Foundation

public struct UserProfile: Codable, Sendable {
    public var id: String
    public var name: String
    public var nickname: String?
    public var position: String?
    public var level: String?
    public var avatarURL: String?
    
    public init(
        id: String = "",
        name: String = "",
        nickname: String? = nil,
        position: String? = nil,
        level: String? = nil,
        avatarURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.position = position
        self.level = level
        self.avatarURL = avatarURL
    }
    
    public var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        return name
    }
    
    public var displayPosition: String {
        if let position = position, !position.isEmpty {
            return position
        }
        return "포지션 선택"
    }
    
    public var displayLevel: String {
        if let level = level, !level.isEmpty {
            return level
        }
        return "실력 선택"
    }
    
    public static let `default` = UserProfile(
        id: "",
        name: "",
        nickname: nil,
        position: nil,
        level: nil,
        avatarURL: nil
    )
}
