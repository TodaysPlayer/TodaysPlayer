//
//  ContentView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("홈", systemImage: "house") {
                NavigationStack {
                    HomeView()
                }
            }
            
            Tab("용병 신청", systemImage: "soccerball") {
                ApplyView()
            }
            
            Tab("나의 매치", systemImage: "checklist") {
                MatchListView()
            }
            
            Tab("프로필", systemImage: "person") {
                MyPageView()
            }
        }
    }
}

#Preview {
    ContentView()
}
