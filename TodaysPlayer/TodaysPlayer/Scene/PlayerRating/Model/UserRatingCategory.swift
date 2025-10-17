//
//  UserRatingCategory.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/17/25.
//

import Foundation

enum UserRatingCategory: CaseIterable, Sendable, Hashable {
    case manner
    case teamwork
    case appointment
    
    var iconName: String {
        switch self {
        case .manner: return "heart"
        case .teamwork: return "person.2"
        case .appointment: return "timer"
        }
    }
    
    var title: String {
        switch self {
        case .manner: return "매너"
        case .teamwork: return "팀워크"
        case .appointment: return "시간약속"
        }
    }
}
