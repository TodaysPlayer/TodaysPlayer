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
    @State private var hasAppeared = false  // 중복 로딩 방지
    
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
                    viewModel: viewModel
                )
                
                // 프로모션 배너
                PromotionalBanner(viewModel: viewModel)
                
                // 하단 여백
                Color.clear
                    .frame(height: 20)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.gray.opacity(0.1))
        .refreshable {
            await viewModel.loadInitialData()
        }
        .onAppear {
            // 중복 호출 방지
            if hasAppeared == false {
                hasAppeared = true
                
                Task {
                    await viewModel.loadInitialData()
                    // 홈 화면 진입 시 위치 권한 요청
                    await viewModel.requestLocationPermission()
                }
            }
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
