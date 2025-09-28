//
//  HomeViewModel.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import Observation

@Observable
class HomeViewModel {
    // 배너 관련
    var currentBannerIndex = 0
    private var bannerTimer: Timer?
    
    // 배너 데이터
    let bannerData = [
        BannerItem(discountTag: "30% OFF", imageName: "HomeBanner1"),
        BannerItem(discountTag: "20% off", imageName: "HomeBanner2")
    ]
    
    // 배너 타이머 관리
    func startBannerTimer() {
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.currentBannerIndex = (self.currentBannerIndex + 1) % self.bannerData.count
                }
            }
        }
    }
    
    func stopBannerTimer() {
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    
    func resetBannerTimer() {
        stopBannerTimer()
        startBannerTimer()
    }
}
