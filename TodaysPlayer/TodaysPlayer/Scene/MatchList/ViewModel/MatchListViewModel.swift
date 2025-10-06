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
    var matchListType: [String]
    var appliedMatchType: [String] = ApplyStatus.allCases.map { $0.filterTitle }
    var myName: String = "용헌"
    var postedMatchCase: PostedMatchCase = .appliedMatch
    
    var selectedMatchType: ApplyStatus = .allType {
        didSet {
            print(selectedMatchType)
            filteringAppliedMatchType(selectedMatchType.rawValue)
        }
    }
    
    init(){
        self.matchListType = PostedMatchCase.allCases
            .map { $0.rawValue }
            .filter { $0 != PostedMatchCase.allMatches.rawValue }
        
        fetchMatchListDatas(selectedType: .appliedMatch)
    }

    /// 매치 데이터 불러오기
    /// - Parameter selectedIndex: 내가 신청한 매치(0) / 내가 모집중인 매치(1) / 종료된 경기
    func fetchMatchListDatas(selectedType: PostedMatchCase) {
        switch selectedType {
        case .appliedMatch:
            appliedMatchType = ApplyStatus.allCases.map { $0.filterTitle }
            matchListDatas = mockMatchData.filter { $0.postUserName != "용헌" }
            postedMatchCase = .appliedMatch
        case .myRecruitingMatch:
            let tempDatas: [MatchInfo] = [mockMatchData.first!]
            // 모집중인 경기 필터링
            appliedMatchType = []
            matchListDatas = tempDatas
            postedMatchCase = .myRecruitingMatch
        case .finishedMatch:
            appliedMatchType = ["전체", "참여한 경기", "모집한 경기"]
            postedMatchCase = .allMatches
            
        default: break
            
        }
    }
    
    /// 신청한 매치 삭제
    func deleteAppliedMatch(matchId: Int) {
        matchListDatas.removeAll { $0.matchId == matchId }
    }
    
    func filteringAppliedMatchType(_ type: String) {

        
        
        let filteredType = ApplyStatus(filterTitle: type)


        if filteredType == .allType {
            matchListDatas = mockMatchData
        }else {
            matchListDatas = mockMatchData.filter { $0.applyStatus == filteredType }
        }

    }
}
