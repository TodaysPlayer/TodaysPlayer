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
                    
                    MyListSegmentedControl(preselectedIndex: 0) {
                        viewModel.fetchMatchListDatas(selectedIndex: $0)
                    }
                    
                    MatchDashboardView()
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matchListDatas, id: \.self) { match in
                                VStack(spacing: 20) {
                                    MatchTagView(
                                        matchInfo: match,
                                        postedMatchCase: viewModel.postedMatchCase
                                    )
                                            
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
                }
                .padding(.horizontal, 20)
            }
        }
    }
}



#Preview {
    MatchListView()
}
