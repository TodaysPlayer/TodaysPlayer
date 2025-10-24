//
//  MatchInfoTag.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

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
        case .futsal: return Color.green
        case .soccer: return Color.blue
        }
    }
    
    var textColor: Color { .white }
    
    var borderColor: Color {
        switch self {
        case .futsal: return Color.green
        case .soccer: return Color.blue
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
        case .deadline: return Color(hex: "#F4B183")
        case .lastOne: return Color(hex: "#FFD966")
        }
    }

    var textColor: Color { .black }

    var borderColor: Color {
        switch self {
        case .deadline: return Color(hex: "#E57C04")
        case .lastOne: return Color(hex: "#F1C232")
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
        case .standby: return Color(hex: "#FFE699")
        case .accepted: return Color(hex: "#A9D18E")
        case .rejected: return Color(hex: "#F4CCCC")
        case .allType: return Color(hex: "#D9D9D9")
        }
    }

    var textColor: Color { .black }

    var borderColor: Color {
        switch self {
        case .standby: return Color(hex: "#E1B800")
        case .accepted: return Color(hex: "#6AA84F")
        case .rejected: return Color(hex: "#CC0000")
        case .allType: return Color(hex: "#B7B7B7")
        }
    }
}


extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}
