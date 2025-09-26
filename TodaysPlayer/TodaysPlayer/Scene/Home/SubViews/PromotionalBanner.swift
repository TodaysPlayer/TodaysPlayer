//
//  PromotionalBanner.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct PromotionalBanner: View {
    let viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            // 메인 배너
            TabView(selection: Binding(
                get: { viewModel.currentBannerIndex },
                set: { viewModel.currentBannerIndex = $0 }
            )) {
                ForEach(0..<viewModel.bannerData.count, id: \.self) { index in
                    BannerItemView(item: viewModel.bannerData[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onChange(of: viewModel.currentBannerIndex) {
                // 수동 스와이핑 시 타이머 초기화
                viewModel.resetBannerTimer()
            }
            .onAppear {
                viewModel.startBannerTimer()
            }
            .onDisappear {
                viewModel.stopBannerTimer()
            }
            .onTapGesture {
                // 배너 클릭 시 상세 페이지로 이동
            }
            
            // 페이지 인디케이터
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                ForEach(0..<viewModel.bannerData.count, id: \.self) { index in
                    Circle()
                        .fill(index == viewModel.currentBannerIndex ? Color.white : Color.white.opacity(0.3))
                        .frame(width: index == viewModel.currentBannerIndex ? 10 : 8, height: index == viewModel.currentBannerIndex ? 10 : 8)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentBannerIndex)
                }
                }
                .padding(.bottom, 16)
            }
        }
    }
}


#Preview {
    PromotionalBanner(viewModel: HomeViewModel())
        .background(Color.gray.opacity(0.1))
}
