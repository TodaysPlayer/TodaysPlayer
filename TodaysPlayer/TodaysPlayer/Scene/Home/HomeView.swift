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
    
    // MARK: - Sample Data Button (개발용)
    private var sampleDataButton: some View {
        VStack(spacing: 8) {
            Button(action: createSampleData) {
                HStack {
                    if isCreatingSampleData {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "plus.circle.fill")
                    }
                    
                    Text(isCreatingSampleData ? "샘플 데이터 생성 중..." : "🔥 샘플 데이터 생성")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange)
                .clipShape(Capsule())
            }
            .disabled(isCreatingSampleData)
            
            Text("개발용: Firebase DB에 샘플 데이터를 생성합니다")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 24)
    }
    private func createSampleData() {
        Task {
            isCreatingSampleData = true
            print("🔥 샘플 데이터 생성 버튼 클릭됨")
            
            do {
                print("🔥 SampleDataManager.createAllSampleData() 호출 시작")
                try await SampleDataManager.shared.createAllSampleData()
                print("🔥 SampleDataManager.createAllSampleData() 완료")
                
                await MainActor.run {
                    isCreatingSampleData = false
                    sampleDataMessage = "샘플 데이터가 성공적으로 생성되었습니다! Firebase 콘솔에서 확인해보세요."
                    showSampleDataAlert = true
                    print("🔥 UI 업데이트 완료")
                    
                    // 데이터 생성 후 새로고침
                    Task {
                        print("🔥 샘플 데이터 생성 후 새로고침")
                        await viewModel.loadInitialData()
                        print("🔥 새로고침 완료")
                    }
                }
            } catch {
                print("❌ 샘플 데이터 생성 중 에러 발생: \(error)")
                print("❌ 에러 타입: \(type(of: error))")
                print("❌ 에러 상세: \(error.localizedDescription)")
                
                await MainActor.run {
                    isCreatingSampleData = false
                    sampleDataMessage = "샘플 데이터 생성 실패: \(error.localizedDescription)\n\nFirebase 연결을 확인해주세요."
                    showSampleDataAlert = true
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
