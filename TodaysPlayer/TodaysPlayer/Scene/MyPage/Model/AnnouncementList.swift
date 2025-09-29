//
//  AnnouncementList.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import Foundation

struct AnnouncementList: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
}

extension AnnouncementList {
    static let samples: [AnnouncementList] = [
        AnnouncementList(
            title: "앱 이용 규정 업데이트 안내",
            content: "풋살/축구 매칭 플랫폼의 건전한 이용 환경 조성을 위해 이용 규정이 업데이트 되었습니다. 새로운 규정을 확인하여 주시기 바랍니다."
        ),
        AnnouncementList(
            title: "새로운 경기 매칭 기능 추가",
            content: "AI 기반 실력 매칭 시스템이 추가되어 더욱 균형잡힌 경기를 즐기실 수 있습니다."
        ),
        AnnouncementList(
            title: "신년 특별 이벤트 - 풋살장 할인 쿠폰",
            content: "1월 한 달간 제휴 풋살장에서 사용 가능한 20% 할인 쿠폰을 증정합니다."
        ),
        AnnouncementList(
            title: "정가 시스템 점검 안내",
            content: "서비스 개선을 위한 정기 점검이 예정되어 있습니다. 점검 시간 동안 일시적으로 서비스 이용이 제한됩니다."
        ),
    ]
}
