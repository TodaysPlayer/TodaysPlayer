//
//  MatchListView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//
//  ⚠️ TODO (2025.10.13 - 소정)
//  ApplyMatchDetailView를 사용하지않게 되어 임시로 주석 처리했습니다.
//
//  해결 방법:
//  1. MatchInfo를 Match로 변환하는 extension 추가
//  2. 또는 MatchListView도 Firebase 데이터로 전환
//
//  참고: FirebaseMatchListView.swift 참고
//

import SwiftUI

struct MatchListView: View {
    @State var viewModel: MatchListViewModel = MatchListViewModel()

    var body: some View {
        NavigationStack{
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    CustomSegmentControlView(
                        categories: viewModel.myMatchSegmentTitles,
                        initialSelection: viewModel.myMatchSegmentTitles.first ?? "신청한 경기") {
                            viewModel.fetchMatchListDatas(selectedType: $0)
                        }
                    
                    MyMatchFilterButtonView(
                        filterTypes: viewModel.filteringButtonTypes,
                        selectedFilter: $viewModel.selectedFilterButton
                    )
                        .padding(.horizontal, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matchListDatas, id: \.self) { match in
                                NavigationLink(
                                    // ⚠️ 임시: ApplyMatchDetailView 삭제로 인한 주석 처리
                                    // TODO: MatchDetailView로 교체 필요
                                    destination: Text("준비중입니다.")
//                                    destination: ApplyMatchDetailView(
//                                        matchInfo: match,
//                                        postedMatchCase: viewModel.postedMatchCase
                                    //)
                                ) {
                                        VStack(spacing: 20) {
                                            MatchTagView(info: match, matchCase: viewModel.postedMatchCase)
                                            MatchInfoView(
                                                matchInfo: match,
                                                postedMatchCase: viewModel.postedMatchCase,
                                                userName: "용헌"
                                            )
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        
                                    }
                                
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("나의 매치 관리")
        }
    
    }
}
