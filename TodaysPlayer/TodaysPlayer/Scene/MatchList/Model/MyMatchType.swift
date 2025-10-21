//
//  MyMatchType.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/6/25.
//

import Foundation

protocol MatchFilterType: Equatable, Hashable {
    var title: String { get }
}

enum MatchFilter: MatchFilterType {
    case applied(AppliedMatch)
    case myRecruting
    case finished(FinishedMatch)
    
    var title: String {
        switch self {
        case .applied(let filter): return filter.title
        case .myRecruting: return ""
        case .finished(let filter): return filter.title
        }
    }
    
    static var appliedCases: [MatchFilter] {
        AppliedMatch.allCases.map { .applied($0) }
    }
    
    static var finishedCases: [MatchFilter] {
        FinishedMatch.allCases.map { .finished($0)}
    }
}


enum AppliedMatch: String, CaseIterable{
    case all = "전체"
    case accepted = "확정된 경기"
    case applied = "대기중인 경기"
    case rejected = "거절된 경기"
    
    var title: String { rawValue }
}

enum FinishedMatch: String, CaseIterable{
    case all = "전체"
    case participated = "참여한 경기"
    case myRecruited = "내가 모집한 경기"
    
    var title: String { rawValue }
}
