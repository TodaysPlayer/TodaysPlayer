//
//  Announcement.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import Foundation

struct Announcement: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
}

extension Announcement {
    static let samples: [Announcement] = [
        Announcement(
            title: "앱 업데이트 안내",
            content: "오늘의 선수 앱이 더 안정적으로 동작하도록 성능을 개선했습니다. 일부 화면의 로딩 속도가 빨라졌으며, 알려진 버그를 수정했습니다. 앞으로도 더 좋은 서비스 제공을 위해 노력하겠습니다."
        ),
        Announcement(
            title: "점검 공지",
            content: "서비스 안정화를 위한 정기 점검이 예정되어 있습니다. 점검 시간 동안 일부 기능이 일시적으로 제한될 수 있습니다. 이용에 불편을 드려 죄송합니다."
        ),
        Announcement(
            title: "이벤트 안내",
            content: "가을 맞이 특별 이벤트가 진행 중입니다! 앱 내에서 특정 미션을 완료하면 포인트를 받을 수 있습니다. 상세 내용은 이벤트 페이지를 참고해 주세요."
        ),
        Announcement(
            title: "알림 설정 방법",
            content: "중요한 소식을 빠르게 받아보시려면 설정 > 알림에서 푸시 알림을 켜 주세요. 필요한 항목만 선택해서 받을 수도 있어요."
        ),
        Announcement(
            title: "데이터 백업 권장",
            content: "앱을 삭제하거나 기기를 변경하기 전에 데이터 백업을 권장드립니다. 설정 > 데이터 관리에서 백업과 복원을 쉽게 진행하실 수 있습니다."
        )
    ]
}
