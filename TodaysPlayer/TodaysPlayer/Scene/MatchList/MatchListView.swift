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
            //248 249 251
            Color.gray.opacity(0.2)
            
            VStack {
                MatchDashboardView()
                MyMatchView()
            }
        }
        .ignoresSafeArea()
    }
}


#Preview {
    MatchListView()
}
