//
//  ToastMessageType.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/2/25.
//

import Foundation


/// ToastMessage 종류
enum ToastMessageType {
    // 신청 관련
    case applyCompleted

    // 게시글 관련
    case postCreated
    case postUpdated
    case postDeleted

    // 신청자 관련
    case participantAccepted
    case participantRejected

    // 본인 내역 관련
    case myRecordDeleted
    
    // MARK: - 표시 문자열
    var message: String {
        switch self {
        case .applyCompleted:           "신청이 완료되었습니다."
        case .postCreated:              "게시글이 작성되었습니다."
        case .postUpdated:              "게시글이 수정되었습니다."
        case .postDeleted:              "게시글이 삭제되었습니다."
        case .participantAccepted:      "신청자를 수락했습니다."
        case .participantRejected:      "신청자를 거절했습니다."
        case .myRecordDeleted:          "내 기록이 삭제되었습니다."
        }
    }
}
