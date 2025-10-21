//
//  ContentView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = TabSelection()
    
    var body: some View {
        TabView(selection: $tabSelection.selectedTab) {
            Tab("홈", systemImage: "house", value: 0) {
                NavigationStack {
                    HomeView()
                }
            }
            
            Tab("용병 모집", systemImage: "soccerball", value: 1) {
                ApplyView()
            }
            
            Tab("나의 경기", systemImage: "checklist", value: 2) {
                MatchListView()
            }
            
            Tab("프로필", systemImage: "person", value: 3) {
                MyPageView()
            }
        }
        .environment(tabSelection)
    }
}

#Preview {
    ContentView()
}
