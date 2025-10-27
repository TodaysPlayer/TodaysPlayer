//
//  MatchInfoTag.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI

import SwiftUI

protocol TagStyle {
    var backgroundColor: Color { get }
    var textColor: Color { get }
    var borderColor: Color { get }
    var title: String { get }
}

// MARK: - 경기 타입
enum MatchType: String, TagStyle, CaseIterable {
    case futsal = "풋살"
    case soccer = "축구"
    
    var title: String { rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .futsal: return .primaryBaseGreen
        case .soccer: return .secondaryMintGreen
        }
    }
    
    var textColor: Color { .white }
    
    var borderColor: Color {
        switch self {
        case .futsal: return .primaryDark
        case .soccer: return .secondaryDeepGray
        }
    }
}

// MARK: - 경기 정보 상태
enum MatchInfoStatus: String, TagStyle {
    case deadline = "마감임박"
    case lastOne = "너만 오면 GO"

    var title: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .deadline: return .accentOrange
        case .lastOne: return .primaryLight
        }
    }

    var textColor: Color { .black }

    var borderColor: Color {
        switch self {
        case .deadline: return .accentOrange
        case .lastOne: return .primaryBaseGreen
        }
    }
}

// MARK: - 신청 상태
enum ApplyStatus: String, TagStyle, CaseIterable {
    case allType = ""
    case standby = "대기중"
    case accepted = "확정"
    case rejected = "거절"
    
    var title: String { rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .standby: return .primaryLight
        case .accepted: return .primaryDark
        case .rejected: return .accentRed
        case .allType: return .secondaryCoolGray
        }
    }

    var textColor: Color {
        switch self {
        default: return .white
        }
    }

    var borderColor: Color {
        switch self {
        case .standby: return .primaryBaseGreen
        case .accepted: return .primaryDark
        case .rejected: return .accentRed
        case .allType: return .secondaryDeepGray
        }
    }
}
