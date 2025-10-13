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
    var myMatchSegmentTitles: [String]
    
    var postedMatchCase: PostedMatchCase = .appliedMatch
    
    var filteringButtonTypes: [MatchFilter]
    var selectedFilterButton: MatchFilter = .applied(.all) {
        didSet {
            print(selectedFilterButton)
        }
    }
    
    init(){
        self.myMatchSegmentTitles = PostedMatchCase.allCases
            .map { $0.rawValue }
            .filter { $0 != PostedMatchCase.allMatches.rawValue }
        
        self.filteringButtonTypes = AppliedMatch.allCases.map { MatchFilter.applied($0) }
        
        fetchMatchListDatas(selectedType: PostedMatchCase.allMatches.rawValue)
    }

    /// 매치 데이터 불러오기
    /// - 상위 세그먼트 (신청한 경기, 내가 모집중인 경기, 종료된 경기) 별로 다른 데이터를 불러와야함
    /// - 하위 필터링 버튼을 통해 불러온 데이터를 필터링
    func fetchMatchListDatas(selectedType: String) {
        guard let type = PostedMatchCase(rawValue: selectedType) else { return }
        switch type {
        case .appliedMatch:
            filteringButtonTypes = MatchFilter.appliedCases
            matchListDatas = mockMatchData.filter { $0.postUserName != "용헌" }
            postedMatchCase = .appliedMatch
        case .myRecruitingMatch:
            let tempDatas: [MatchInfo] = [mockMatchData.first!]
            // 모집중인 경기 필터링
            filteringButtonTypes = []
            matchListDatas = tempDatas
            postedMatchCase = .myRecruitingMatch
        case .finishedMatch:
            filteringButtonTypes = MatchFilter.finishedCases
            postedMatchCase = .finishedMatch
            
        default: break
            
        }
    }
    
    /// 신청한 매치 삭제
    func deleteAppliedMatch(matchId: Int) {
        matchListDatas.removeAll { $0.matchId == matchId }
    }
}
