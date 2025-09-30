//
//  PopupCase.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import Foundation

/// 팝업종류
enum PopupType {
    case deletePostedMatch
    case deleteAppliedMatch
    case acceptAppliedUser
    
    var title: String {
        switch self {
        case .deletePostedMatch: "작성한 경기를 삭제할까요?"
        case .deleteAppliedMatch: "신청한 경기를 삭제할까요?"
        case .acceptAppliedUser: "해당 신청을 수락할까요?"
        }
    }
    
    var description: String {
        switch self {
        case .deletePostedMatch: "삭제하면 해당 경기를 다시 찾을 수 없어요"
        case .deleteAppliedMatch: "삭제하면 신청 내역을 다시 찾을 수 없어요"
        case .acceptAppliedUser: "수락 후, 취소가 어려워요"
        }
    }
    
    var rightButtonTitle: String {
        switch self {
        case .acceptAppliedUser: "수락"
        default: "취소"
        }
    }
}

