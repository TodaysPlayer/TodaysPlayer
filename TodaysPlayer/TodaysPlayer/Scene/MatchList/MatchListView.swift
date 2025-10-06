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
                    Text("나의 매치 관리")
                        .font(.title)
                        .bold()
                        .padding(.horizontal, 20)

                    ParticipantSegmentControlView(
                        categories: viewModel.matchListType,
                        initialSelection: viewModel.matchListType.first ?? "신청한 경기") {
                            viewModel.fetchMatchListDatas(selectedType: $0)
                        }
                    
                    MyMatchFilterButtonView(
                        titles: viewModel.appliedMatchType,
                        selectedTitle: $viewModel.selectedMatchType
                    )
                        .padding(.horizontal, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matchListDatas, id: \.self) { match in
                                VStack(spacing: 20) {
                                    MatchTagView(
                                        matchInfo: match,
                                        postedMatchCase: viewModel.postedMatchCase,
                                    ) {
                                        viewModel.deleteAppliedMatch(matchId: $0)
                                    }
                                            
                                    MatchInfoView(
                                        matchInfo: match,
                                        postedMatchCase: viewModel.postedMatchCase
                                    )
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    MatchListView()
}
