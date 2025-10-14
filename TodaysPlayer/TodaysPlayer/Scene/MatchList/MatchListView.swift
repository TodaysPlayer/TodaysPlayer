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
                
                VStack(alignment: .leading, spacing: 15) {
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
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if !viewModel.isLoading && viewModel.displayedMatches.isEmpty {
                                Text("매치 데이터가 없습니다")
                                    .foregroundColor(.gray)
                            }

                            ForEach(Array(viewModel.displayedMatches.enumerated()), id: \.element.id) { index, match in
                                NavigationLink(destination: MatchDetailView(match: match)) {
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
                                .onAppear {
                                    // 여기에서 마지막 확인해야함------
                                    let prefetchThreshold = 1 // 마지막 1개 지점에서 프리패치
                                    let shouldPrefetch = index >= max(0, viewModel.displayedMatches.count - prefetchThreshold)
                                    if shouldPrefetch && !viewModel.isLoading && !viewModel.isLoadingMore && viewModel.hasMore {
                                        Task { await viewModel.loadMoreMatches() }
                                    } else if index >= max(0, viewModel.displayedMatches.count - 1) && !viewModel.hasMore {
                                        Task { await viewModel.pulseEndIndicator() }
                                    }
                                }
                            }

                            if viewModel.isLoadingMore || viewModel.showEndPulse {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text(viewModel.hasMore ? "더 불러오는 중..." : "마지막 데이터를 확인 중...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.vertical)
                    }
                    .scrollIndicators(.hidden)
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("나의 매치 관리")

        }
    }
}

#Preview {
    MatchListView()
}
