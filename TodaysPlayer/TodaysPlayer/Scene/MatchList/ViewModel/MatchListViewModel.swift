//
//  MatchListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI

@Observable
final class MatchListViewModel {
    var matchListDatas: [MatchInfo] = mockMatchData.filter { $0.postUserName != "용헌" }
    var myName: String = "용헌"
    var postedMatchCase: PostedMatchCase = .appliedMatch
    
    
    /// 매치 데이터 불러오기
    /// - Parameter selectedIndex: 내가 신청한 매치(0) / 내가 작성한 매치(1)
    func fetchMatchListDatas(selectedIndex: Int) {
        if selectedIndex == 0 {
            // 신청한 경기 필터링
            matchListDatas = mockMatchData.filter { $0.postUserName != "용헌" }
            postedMatchCase = .appliedMatch
        } else {
            let tempDatas: [MatchInfo] = [mockMatchData.first!]
            // 모집중인 경기 필터링
            matchListDatas = tempDatas
            postedMatchCase = .myRecruitingMatch
        }
    }
    
    /// 신청한 매치 삭제
    func deleteAppliedMatch(matchId: Int) {
        matchListDatas.removeAll { $0.matchId == matchId }
    }
}
