//
//  HomeView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 다음 경기
                NextMatchCard()
                    .padding(.top, 24)
                
                // 내 주변 가까운 매치
                NearbyMatchesCard()
                
                // 내 활동 통계
                ActivityStatsCard()
                
                // 프로모션 배너
                PromotionalBanner(viewModel: viewModel)
                
                // 하단 여백
                Color.clear
                    .frame(height: 20)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    HomeView()
}
