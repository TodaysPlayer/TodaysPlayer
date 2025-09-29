//
//  MatchListView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchListView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("나의 매치 관리")
                    .font(.title)
                    .bold()
                
                MyListSegmentedControl(preselectedIndex: 0)
                    .padding(.horizontal, 10)

                MatchDashboardView()
                    .padding(.horizontal, 10)
                
                List(mockMatchData, id: \.self) { match in
                    MyMatchView(testMatchData: match)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 5)
                }
                .listRowSpacing(20)
                .scrollContentBackground(.hidden)
            }
            .padding(.horizontal)
        }
    }
}



#Preview {
    MatchListView()
    
}
