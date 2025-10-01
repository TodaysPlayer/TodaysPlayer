//
//  RejectCase.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/1/25.
//

import Foundation

/// 거절사유 case
enum RejectCase: String, CaseIterable {
    case teamGoal =  "이 경기의 목표와 맞지 않습니다"
    case teamCondition = "팀원 조건과 맞지 않습니다(실력, 성별 등)"
    case shortIntro =  "소개글이 짧아서 어떤 분인지 알 수 없습니다"
    case etc = "기타(직접 작성)"

    var title: String { rawValue }
}
