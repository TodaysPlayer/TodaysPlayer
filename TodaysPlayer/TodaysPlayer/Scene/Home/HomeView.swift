//
//  HomeView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var isCreatingSampleData = false
    @State private var isAddingRating = false
    @State private var showSampleDataAlert = false
    @State private var sampleDataMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 다음 경기
                NextMatchCard(
                    user: viewModel.user,
                    nextMatch: viewModel.getNextMatch()
                )
                .padding(.top, 24)
                
                // 내 주변 가까운 매치
                NearbyMatchesCard(
                    matches: viewModel.getNearbyMatches(),
                    hasLocationPermission: viewModel.hasLocationPermission(),
                    formatDistance: { coordinates in
                        viewModel.formatDistance(to: coordinates)
                    },
                    onRequestLocationPermission: {
                        Task {
                            await viewModel.requestLocationPermission(shouldOpenSettings: true)
                        }
                    }
                )
                
                // 프로모션 배너
                PromotionalBanner(bannerData: viewModel.bannerData)
                    .padding(.bottom, 20)   // 하단 여백
            }
            .padding(.horizontal, 24)
        }
        .background(Color.gray.opacity(0.1))
        .refreshable {
            await viewModel.loadInitialData()
        }
        .task {
            await viewModel.loadInitialData()
            await viewModel.requestLocationPermission() // 홈 화면 진입 시 위치 권한 요청
        }
        .alert("샘플 데이터 생성", isPresented: $showSampleDataAlert) {
            Button("확인") { }
        } message: {
            Text(sampleDataMessage)
        }
    }
}

#Preview {
    HomeView()
}
