//
//  MatchListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI
import Combine

@Observable
final class MatchListViewModel {
    var matchListDatas: [MatchInfo] = mockMatchData.filter { $0.postUserName != "용헌" }
    var matchListType: [String] = ["신청한 경기", "내가 모집중인 경기", "종료된 경기"]
    var appliedMatchType: [String] = ApplyStatus.allCases.map { $0.filterTitle }
    var myName: String = "용헌"
    var postedMatchCase: PostedMatchCase = .appliedMatch
    
    var selectedMatchType: String = "" {
        didSet {
            filteringAppliedMatchType(selectedMatchType)
        }
    }

    
    /// 매치 데이터 불러오기
    /// - Parameter selectedIndex: 내가 신청한 매치(0) / 내가 작성한 매치(1)
    func fetchMatchListDatas(selectedIndex: String) {
        if selectedIndex == matchListType[0] {
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
    
    func filteringAppliedMatchType(_ type: String) {

        let test = ApplyStatus(filterTitle: type)

        
        if test == .allType {
            matchListDatas = mockMatchData
        }else {
            matchListDatas = mockMatchData.filter { $0.applyStatus == test }
        }

    }
}
