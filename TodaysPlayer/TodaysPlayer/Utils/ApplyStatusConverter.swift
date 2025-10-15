//
//  ConvertApplyStatus.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/15/25.
//

import Foundation


/// 신청상태 변환
enum ApplyStatusConverter {
    static func toStatus(from string: String) -> ApplyStatus {
        switch string.lowercased() {
        case "accepted": return .accepted
        case "pending": return .standby
        case "rejected": return .rejected
        default: return .allType
        }
    }

    static func toString(from status: ApplyStatus) -> String {
        switch status {
        case .accepted: return "accepted"
        case .standby: return "pending"
        case .rejected: return "rejected"
        case .allType: return "all"
        }
    }
}
