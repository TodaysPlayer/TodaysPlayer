//
//  MatchListView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
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
                    
//                    ScrollView {
//                        LazyVStack(spacing: 16) {
//                            ForEach(viewModel.displayedMatches, id: \.self) { match in
//                                NavigationLink(
//                                    
//                                    // TODO: MatchDetailView로 교체 필요
//                                    destination: Text("준비중입니다.")
////                                    destination: ApplyMatchDetailView(
////                                        matchInfo: match,
////                                        postedMatchCase: viewModel.postedMatchCase
//                                    //)
//                                ) {
//                                        VStack(spacing: 20) {
//                                            MatchTagView(info: match, matchCase: viewModel.postedMatchCase)
//                                            MatchInfoView(
//                                                matchInfo: match,
//                                                postedMatchCase: viewModel.postedMatchCase,
//                                                userName: "용헌"
//                                            )
//                                        }
//                                        .padding()
//                                        .background(Color.white)
//                                        .cornerRadius(12)
//                                        
//                                    }
//                                    .onAppear {
////                                        if match == viewModel.matches.last {
//                                            Task {
//                                                await viewModel.loadMoreMatches()
//                                            }
////                                        }
//                                    }
//                                
//                                if viewModel.isLoading {
//                                    ProgressView("불러오는 중...")
//                                        .padding()
//                                }
//                            }
//                            
//                        }
//                        .padding(.vertical)
//                    }
                    .padding(.horizontal, 20)
                }
            }
            .task({
                await viewModel.loadInitialMatches()
            })
            .navigationTitle("나의 매치 관리")
        }
        
    }
}

#Preview {
    MatchListView()
}
