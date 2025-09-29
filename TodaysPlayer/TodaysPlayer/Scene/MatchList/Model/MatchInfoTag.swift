//
//  MatchInfoTag.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI

protocol MatchInfoTag {
    var backgroundColor: Color { get }
    var textColor: Color { get }
    var borderColor: Color { get }
    var title: String { get }
}
 
/// 경기타입 태그 enum
enum MatchTypeTags: String, MatchInfoTag {
    case futsal = "풋살"
    case soccer = "축구"
    
    var title: String { rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .futsal: .green
        case .soccer: .blue
        }
    }
    
    var textColor: Color {
        switch self {
        case .futsal: .white
        case .soccer: .white
        }
    }
    
    var borderColor: Color {
        switch self {
        case .futsal: .green
        case .soccer: .blue
        }
    }
}

enum MatchStatusTag: String, MatchInfoTag {
    case deadline = "마감임박"
    case lastOne = "너만 오면 GO"

    var title: String { rawValue }

    var backgroundColor: Color {
        switch self {
        case .deadline: .red
        case .lastOne: .orange
        }
    }

    var textColor: Color { .white }

    var borderColor: Color {
        switch self {
        case .deadline: .red
        case .lastOne: .orange
        }
    }
}
