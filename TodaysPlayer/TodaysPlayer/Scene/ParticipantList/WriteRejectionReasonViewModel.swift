//
//  WriteRejectionReason.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/1/25.
//

import SwiftUI

@Observable
final class WriteRejectionReasonViewModel {
    var textEditor: String = ""
    let limit: Int = 200
    
    
    /// 신청자 거절하기
    /// - Parameter personInfo: 신청자의 정보
    func rejectAppliedPerson(_ personInfo: ParticipantEntity ) {
        
    }
}
