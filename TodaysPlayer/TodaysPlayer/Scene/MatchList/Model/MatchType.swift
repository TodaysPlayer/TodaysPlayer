//
//  MatchCase.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import Foundation


/// 매치 게시글 종류
enum PostedMatchCase: String, CaseIterable {
    case allMatches = "전체"
    case appliedMatch = "신청한 경기"
    case myRecruitingMatch = "내가 모집중인 경기"
    case finishedMatch = "종료된 경기"
}

