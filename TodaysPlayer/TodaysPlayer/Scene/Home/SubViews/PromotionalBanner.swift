//
//  PromotionalBanner.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import Combine

struct PromotionalBanner: View {
    @Environment(\.openURL) var openURL
    
    @State var viewModel: HomeViewModel
    @State private var currentIndex = 0
    @State private var isDragging = false
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 메인 배너
            TabView(selection: $currentIndex) {
                // 순환 리스트에서 첫 번째와 마지막 아이템을 추가
                ForEach(-1..<viewModel.bannerData.count + 1, id: \.self) { i in
                    let item = viewModel.bannerData[i < 0 ? viewModel.bannerData.count - 1 : (i >= viewModel.bannerData.count ? 0 : i)]
                    
                    BannerItemView(bannerItem: item)
                        .tag(i)
                        .onTapGesture {
                            openURL(URL(string: item.link)!)
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .simultaneousGesture( // delay를 두지 않고, 바로 제스쳐를 감지
                DragGesture()   // 드래그 감지
                    .onChanged { _ in
                        // 드래그 중 타이머 중지
                        isDragging = true
                        
                        timer.upstream.connect().cancel()
                    }
                    .onEnded { _ in
                        // 드래그 종료 시, 타이머 재활성화
                        isDragging = false
                        getInfiniteScrollIndex()
                        
                        timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
                    }
            )
            .onChange(of: currentIndex) { _, _ in
                if !isDragging {
                    // 드래그 중이 아닐 경우에만 페이지 세팅
                    getInfiniteScrollIndex()
                }
            }
            .onReceive(timer) { _ in
                // 타이머 가동 시, 인덱스 하나씩 옮김
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex += 1
                }
            }
            
            // 페이지 인디케이터
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.bannerData.count, id: \.self) { index in
                        Circle()
                            .fill(index == getRealIndex() ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == getRealIndex() ? 10 : 8, height: index == getRealIndex() ? 10 : 8)
                            .animation(.easeInOut(duration: 0.3), value: getRealIndex())
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// 무한 스크롤 구현
    private func getInfiniteScrollIndex() {
        if currentIndex == viewModel.bannerData.count {
            // 처음으로 갔을 때 끝쪽으로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentIndex = 0
            }
        } else if currentIndex < 0 {
            // 마지막으로 갔을 때 첫쪽으로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentIndex = viewModel.bannerData.count - 1
            }
        }
    }
    
    /// 실제 인덱스 계산 (인디케이터용)
    private func getRealIndex() -> Int {
        if currentIndex < 0 {
            return viewModel.bannerData.count - 1
        } else if currentIndex >= viewModel.bannerData.count {
            return 0
        } else {
            return currentIndex
        }
    }
}

#Preview {
    PromotionalBanner(viewModel: HomeViewModel())
        .background(Color.gray.opacity(0.1))
}
