//
//  MatchListViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/29/25.
//

import SwiftUI

@Observable
final class MatchListViewModel {
    var matchListDatas: [MatchInfo] = mockMatchData
    
    func fetchMatchListDatas(selectedIndex: Int) {
        if selectedIndex == 0 {
            // 신청한 경기 필터링
            matchListDatas = mockMatchData
        } else {
            let tempDatas: [MatchInfo] = [mockMatchData.first!]
            // 모집중인 경기 필터링
            matchListDatas = tempDatas
        }
    }
}
