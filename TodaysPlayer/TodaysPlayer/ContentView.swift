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
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            
            Tab("Apply", systemImage: "house") {
                ApplyView()
            }
            
            Tab("Navigation", systemImage: "house") {
                MatchListView()
            }
            
            Tab("MyPage", systemImage: "house") {
                MyPageView()
            }
        }
    }
}

#Preview {
    ContentView()
}
