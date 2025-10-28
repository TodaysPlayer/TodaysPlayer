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
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
     
                VStack(alignment: .leading) {
                    Text("나의 경기관리")
                        .font(.title.bold())
                        .padding(.leading, 22)
                        .padding(.top, 8)
                    
                    CustomSegmentControlView(
                        categories: viewModel.myMatchSegmentTitles,
                        initialSelection: viewModel.myMatchSegmentTitles.first ?? "신청한 경기"
                    ) {
                        viewModel.fetchFilteringButtonTitle(selectedType: $0)
                    }
                    
                    MyMatchFilterButtonView(
                        filterTypes: viewModel.filteringButtonTypes,
                        selectedFilter: $viewModel.selectedFilterButton
                    )
                    .padding(.horizontal, 10)
                    .visible(!viewModel.filteringButtonTypes.isEmpty)
                    
                    SortSheetButtonView(selectedOption: $viewModel.sortOption)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if !viewModel.isLoading && viewModel.displayedMatches.isEmpty {
                                Text("경기 데이터가 없습니다")
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(Array(viewModel.displayedMatches.enumerated()), id: \.element.id) { index, match in
                                NavigationLink(value: match) {
                                    MatchInfoView(
                                        matchInfo: match,
                                        postedMatchCase: viewModel.postedMatchCase,
                                        apply: viewModel.getUserApplyStatus(appliedMatch: match),
                                        matchTagInfo: viewModel.getTagInfomation(with: match),
                                        finishedMatchId: $viewModel.finishedMatchId,
                                        finishedMatchWithRatingId: $viewModel.finishedMatchWithRatingId
                                    )
                                    .padding()
                                    .background(checkRejectMatch(match)
                                                ? Color.gray.opacity(0.2) : Color.white)
                                    .cornerRadius(12)

                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal, 2)
                                .onAppear {
                                    if index == viewModel.displayedMatches.count - 1 {
                                        Task { await viewModel.loadMoreMatches() }
                                    }
                                }
                            }
                            if viewModel.isLoading && !viewModel.displayedMatches.isEmpty {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("불러오는 중...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        viewModel.fetchMyMatchData()
                    }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal, 24)
                    .navigationDestination(for: Match.self) { match in
                        MatchDetailView(match: match)
                    }
                }
                
                ToastMessageView(manager: viewModel.toastManager)
            }

            .onAppear {
                viewModel.fetchMyMatchData()
            }
            .alert("해당 경기를 종료할까요?", isPresented: $viewModel.isFinishMatchAlertShow) {
                Button("취소", role: .cancel) { }
                
                Button("종료", role: .close) {
                    Task { await viewModel.finishSelectedMatch() }
                }
                .modifier(MyMatchButtonStyle())
            }
        }
    }
    
    private func checkRejectMatch(_ match: Match) -> Bool {
        let applyStatus = viewModel.getUserApplyStatus(appliedMatch: match)
        return applyStatus.2 == .rejected
    }

}
